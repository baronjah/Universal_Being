extends Node

class_name TokenSystem

# Token Economy System for Eden_OS
# Manages value exchange, creation tokens, and cryptocurrency integration

signal token_created(token_name, initial_supply)
signal token_transferred(from_user, to_user, token_name, amount)
signal value_changed(token_name, new_value)
signal creation_rewarded(user, token_name, amount, reason)

# Token types
const TOKEN_TYPES = {
    "CREATION": {"symbol": "CRE", "color": Color(0.2, 0.8, 0.2), "max_supply": 1000000},
    "DIMENSION": {"symbol": "DIM", "color": Color(0.2, 0.2, 0.8), "max_supply": 100000},
    "WORD": {"symbol": "WRD", "color": Color(0.8, 0.2, 0.2), "max_supply": 10000000},
    "FLOW": {"symbol": "FLW", "color": Color(0.8, 0.8, 0.2), "max_supply": 500000},
    "WISH": {"symbol": "WSH", "color": Color(0.8, 0.2, 0.8), "max_supply": 12000},
    "SATOSHI": {"symbol": "SAT", "color": Color(1.0, 0.5, 0.0), "max_supply": 2100000000000000}
}

# Token economy state
var token_supply = {}
var token_balances = {}
var token_transactions = []
var token_value = {}
var token_exchange_rates = {}

# Creation rewards
var creation_rewards = {
    "new_word": {"token": "WORD", "amount": 10},
    "new_dimension": {"token": "DIMENSION", "amount": 100},
    "new_game": {"token": "CREATION", "amount": 1000},
    "new_connection": {"token": "FLOW", "amount": 5},
    "command_execution": {"token": "WISH", "amount": 1},
    "turn_completion": {"token": "CREATION", "amount": 5}
}

# Cryptocurrency integration
var crypto_wallets = {}
var crypto_networks = ["bitcoin", "ethereum", "polkadot"]
var crypto_exchange_rate = {}

func _ready():
    initialize_token_system()
    print("Token Economy System initialized with " + str(TOKEN_TYPES.size()) + " token types")

func initialize_token_system():
    # Initialize token supply and values
    for token_type in TOKEN_TYPES:
        token_supply[token_type] = 0
        token_value[token_type] = randf_range(0.1, 10.0)
        
        # Initialize exchange rates between tokens
        token_exchange_rates[token_type] = {}
        for other_token in TOKEN_TYPES:
            if token_type != other_token:
                token_exchange_rates[token_type][other_token] = token_value[token_type] / token_value[other_token]
    
    # Initialize crypto exchange rates
    crypto_exchange_rate["bitcoin"] = 30000.0
    crypto_exchange_rate["ethereum"] = 2000.0
    crypto_exchange_rate["polkadot"] = 5.0
    
    # Create initial tokens
    create_initial_tokens()
    
    # Initialize JSH's wallet
    ensure_wallet("JSH")
    for nickname in ["BaronJah", "lolelitaman", "hotshot12", "hotshot1211", "baronjahpl", "baaronjah", "baronjah0", "baronjah5"]:
        ensure_wallet(nickname)
        
    # Give initial tokens to JSH
    add_tokens("JSH", "CREATION", 10000)
    add_tokens("JSH", "DIMENSION", 5000)
    add_tokens("JSH", "WORD", 50000)
    add_tokens("JSH", "FLOW", 10000)
    add_tokens("JSH", "WISH", 1200)
    add_tokens("JSH", "SATOSHI", 2100000)

func create_initial_tokens():
    # Mint initial token supply
    for token_type in TOKEN_TYPES:
        var initial_supply = TOKEN_TYPES[token_type]["max_supply"] * 0.1  # Start with 10% of max supply
        token_supply[token_type] = initial_supply
        emit_signal("token_created", token_type, initial_supply)

func ensure_wallet(username):
    # Create wallet for user if it doesn't exist
    if not token_balances.has(username):
        token_balances[username] = {}
        
        for token_type in TOKEN_TYPES:
            token_balances[username][token_type] = 0
        
        return true
    
    return false

func add_tokens(username, token_type, amount):
    # Add tokens to user's wallet
    if not token_balances.has(username):
        ensure_wallet(username)
    
    if not TOKEN_TYPES.has(token_type):
        return "Invalid token type: " + token_type
    
    token_balances[username][token_type] += amount
    
    # Record transaction
    token_transactions.append({
        "type": "mint",
        "token": token_type,
        "to": username,
        "amount": amount,
        "time": Time.get_unix_time_from_system()
    })
    
    return "Added " + str(amount) + " " + TOKEN_TYPES[token_type]["symbol"] + " to " + username

func transfer_tokens(from_user, to_user, token_type, amount):
    # Transfer tokens between users
    if not token_balances.has(from_user):
        return "Source user " + from_user + " does not have a wallet"
    
    if not token_balances.has(to_user):
        ensure_wallet(to_user)
    
    if not TOKEN_TYPES.has(token_type):
        return "Invalid token type: " + token_type
    
    if token_balances[from_user][token_type] < amount:
        return "Insufficient balance: " + from_user + " has " + str(token_balances[from_user][token_type]) + " " + TOKEN_TYPES[token_type]["symbol"]
    
    # Perform transfer
    token_balances[from_user][token_type] -= amount
    token_balances[to_user][token_type] += amount
    
    # Record transaction
    token_transactions.append({
        "type": "transfer",
        "token": token_type,
        "from": from_user,
        "to": to_user,
        "amount": amount,
        "time": Time.get_unix_time_from_system()
    })
    
    # Emit signal
    emit_signal("token_transferred", from_user, to_user, token_type, amount)
    
    return "Transferred " + str(amount) + " " + TOKEN_TYPES[token_type]["symbol"] + " from " + from_user + " to " + to_user

func reward_creation(username, action_type):
    # Reward user for creative actions
    if not creation_rewards.has(action_type):
        return "Unknown action type: " + action_type
    
    var reward = creation_rewards[action_type]
    var token_type = reward["token"]
    var amount = reward["amount"]
    
    # Add tokens
    add_tokens(username, token_type, amount)
    
    # Emit signal
    emit_signal("creation_rewarded", username, token_type, amount, action_type)
    
    return "Rewarded " + username + " with " + str(amount) + " " + TOKEN_TYPES[token_type]["symbol"] + " for " + action_type

func exchange_tokens(username, from_token, to_token, amount):
    # Exchange one token type for another
    if not token_balances.has(username):
        return "User " + username + " does not have a wallet"
    
    if not TOKEN_TYPES.has(from_token) or not TOKEN_TYPES.has(to_token):
        return "Invalid token type"
    
    if token_balances[username][from_token] < amount:
        return "Insufficient balance"
    
    # Calculate exchange amount
    var rate = token_exchange_rates[from_token][to_token]
    var received_amount = amount * rate * 0.98  # 2% exchange fee
    
    # Perform exchange
    token_balances[username][from_token] -= amount
    token_balances[username][to_token] += received_amount
    
    # Record transaction
    token_transactions.append({
        "type": "exchange",
        "user": username,
        "from_token": from_token,
        "to_token": to_token,
        "from_amount": amount,
        "to_amount": received_amount,
        "rate": rate,
        "time": Time.get_unix_time_from_system()
    })
    
    return "Exchanged " + str(amount) + " " + TOKEN_TYPES[from_token]["symbol"] + " for " + str(received_amount) + " " + TOKEN_TYPES[to_token]["symbol"]

func update_token_values():
    # Simulate market forces affecting token values
    for token_type in TOKEN_TYPES:
        var change = randf_range(-0.05, 0.05)  # -5% to +5% change
        token_value[token_type] *= (1.0 + change)
        
        # Update exchange rates
        for other_token in TOKEN_TYPES:
            if token_type != other_token:
                token_exchange_rates[token_type][other_token] = token_value[token_type] / token_value[other_token]
        
        # Emit signal
        emit_signal("value_changed", token_type, token_value[token_type])

func integrate_crypto_wallet(username, network, address, private_key=""):
    # Add cryptocurrency wallet to user
    if not crypto_wallets.has(username):
        crypto_wallets[username] = {}
    
    crypto_wallets[username][network] = {
        "address": address,
        "balance": 0,
        "private_key": private_key,  # Store securely or don't store at all in a real app
        "transactions": []
    }
    
    return "Integrated " + network + " wallet for " + username

func simulate_crypto_transaction(username, network, amount, is_receive=true):
    # Simulate receiving or sending cryptocurrency
    if not crypto_wallets.has(username) or not crypto_wallets[username].has(network):
        return "No " + network + " wallet found for " + username
    
    var wallet = crypto_wallets[username][network]
    
    if is_receive:
        wallet["balance"] += amount
        wallet["transactions"].append({
            "type": "receive",
            "amount": amount,
            "time": Time.get_unix_time_from_system()
        })
        
        return "Received " + str(amount) + " " + network + " to " + username + "'s wallet"
    else:
        if wallet["balance"] < amount:
            return "Insufficient balance in " + network + " wallet"
            
        wallet["balance"] -= amount
        wallet["transactions"].append({
            "type": "send",
            "amount": amount,
            "time": Time.get_unix_time_from_system()
        })
        
        return "Sent " + str(amount) + " " + network + " from " + username + "'s wallet"

func convert_satoshi_to_bitcoin(satoshi_amount):
    # Convert satoshi to bitcoin (1 BTC = 100,000,000 Satoshi)
    return satoshi_amount / 100000000.0

func get_wallet_balance(username, token_type=null):
    # Get wallet balance for user
    if not token_balances.has(username):
        return "User " + username + " does not have a wallet"
    
    if token_type != null:
        if not TOKEN_TYPES.has(token_type):
            return "Invalid token type: " + token_type
            
        return token_balances[username][token_type]
    else:
        var balances = "Balances for " + username + ":\n"
        
        for token in TOKEN_TYPES:
            if token_balances[username][token] > 0:
                balances += TOKEN_TYPES[token]["symbol"] + ": " + str(token_balances[username][token])
                
                # Add value in USD for reference
                var usd_value = token_balances[username][token] * token_value[token]
                balances += " (≈$" + str(snappedf(usd_value, 0.01)) + ")\n"
        
        return balances

func get_token_info(token_type):
    # Get information about a token
    if not TOKEN_TYPES.has(token_type):
        return "Invalid token type: " + token_type
    
    var info = "Token: " + token_type + " (" + TOKEN_TYPES[token_type]["symbol"] + ")\n"
    info += "Supply: " + str(token_supply[token_type]) + " / " + str(TOKEN_TYPES[token_type]["max_supply"]) + "\n"
    info += "Value: $" + str(snappedf(token_value[token_type], 0.01)) + "\n"
    
    info += "Exchange Rates:\n"
    for other_token in TOKEN_TYPES:
        if token_type != other_token:
            info += "  1 " + TOKEN_TYPES[token_type]["symbol"] + " = " + str(snappedf(token_exchange_rates[token_type][other_token], 0.001)) + " " + TOKEN_TYPES[other_token]["symbol"] + "\n"
    
    return info

func get_transaction_history(username=null, limit=10):
    # Get transaction history for user or all transactions
    var transactions = []
    
    if username != null:
        for tx in token_transactions:
            if (tx.has("from") and tx["from"] == username) or (tx.has("to") and tx["to"] == username) or (tx.has("user") and tx["user"] == username):
                transactions.append(tx)
    else:
        transactions = token_transactions
    
    # Sort by time (newest first)
    transactions.sort_custom(func(a, b): return a["time"] > b["time"])
    
    # Limit number of results
    if transactions.size() > limit:
        transactions = transactions.slice(0, limit - 1)
    
    var history = "Transaction History" + (" for " + username if username != null else "") + ":\n"
    
    for tx in transactions:
        var timestamp = Time.get_datetime_string_from_unix_time(tx["time"])
        
        match tx["type"]:
            "mint":
                history += timestamp + ": Minted " + str(tx["amount"]) + " " + TOKEN_TYPES[tx["token"]]["symbol"] + " to " + tx["to"] + "\n"
            "transfer":
                history += timestamp + ": " + tx["from"] + " → " + tx["to"] + ": " + str(tx["amount"]) + " " + TOKEN_TYPES[tx["token"]]["symbol"] + "\n"
            "exchange":
                history += timestamp + ": " + tx["user"] + " exchanged " + str(tx["from_amount"]) + " " + TOKEN_TYPES[tx["from_token"]]["symbol"] + " for " + str(tx["to_amount"]) + " " + TOKEN_TYPES[tx["to_token"]]["symbol"] + "\n"
    
    return history

func process_command(args):
    if args.size() == 0:
        return "Token Economy System. Use 'token balance', 'token transfer', 'token info', 'token exchange'"
    
    match args[0]:
        "balance":
            if args.size() < 2:
                return get_wallet_balance(UserProfiles.active_user)
                
            return get_wallet_balance(args[1])
        "transfer":
            if args.size() < 4:
                return "Usage: token transfer <to_user> <token_type> <amount>"
                
            var to_user = args[1]
            var token_type = args[2].to_upper()
            var amount = float(args[3])
            
            return transfer_tokens(UserProfiles.active_user, to_user, token_type, amount)
        "info":
            if args.size() < 2:
                var info = "Available Tokens:\n"
                
                for token in TOKEN_TYPES:
                    info += "- " + token + " (" + TOKEN_TYPES[token]["symbol"] + "): $" + str(snappedf(token_value[token], 0.01)) + "\n"
                    
                return info
                
            return get_token_info(args[1].to_upper())
        "exchange":
            if args.size() < 4:
                return "Usage: token exchange <from_token> <to_token> <amount>"
                
            var from_token = args[1].to_upper()
            var to_token = args[2].to_upper()
            var amount = float(args[3])
            
            return exchange_tokens(UserProfiles.active_user, from_token, to_token, amount)
        "rewards":
            return show_creation_rewards()
        "market":
            update_token_values()
            return "Token market values updated"
        "history":
            if args.size() < 2:
                return get_transaction_history(UserProfiles.active_user)
                
            return get_transaction_history(args[1])
        "satoshi":
            if args.size() < 2:
                return get_wallet_balance(UserProfiles.active_user, "SATOSHI")
                
            var amount = float(args[1])
            return "Satoshi value: " + str(amount) + " SAT = " + str(convert_satoshi_to_bitcoin(amount)) + " BTC ≈ $" + str(convert_satoshi_to_bitcoin(amount) * crypto_exchange_rate["bitcoin"])
        "crypto":
            if args.size() < 2:
                var info = "Cryptocurrency Networks:\n"
                
                for network in crypto_networks:
                    info += "- " + network + ": $" + str(crypto_exchange_rate[network]) + "\n"
                    
                return info
                
            if args[1] == "integrate" and args.size() >= 4:
                return integrate_crypto_wallet(UserProfiles.active_user, args[2], args[3])
            elif args[1] == "receive" and args.size() >= 4:
                return simulate_crypto_transaction(UserProfiles.active_user, args[2], float(args[3]), true)
            elif args[1] == "send" and args.size() >= 4:
                return simulate_crypto_transaction(UserProfiles.active_user, args[2], float(args[3]), false)
                
            return "Unknown crypto command. Try 'integrate', 'receive', or 'send'"
        _:
            return "Unknown token command: " + args[0]

func show_creation_rewards():
    var info = "Creation Rewards:\n"
    
    for action in creation_rewards:
        var reward = creation_rewards[action]
        info += "- " + action + ": " + str(reward["amount"]) + " " + TOKEN_TYPES[reward["token"]]["symbol"] + "\n"
        
    return info

func snappedf(value, step):
    # Round to nearest step (e.g. 0.01 for cents)
    return round(value / step) * step