extends Node
class_name JSHQueryLanguage

# The JSHQueryLanguage system provides a flexible query language for searching entities
# It allows for complex queries with filtering, sorting, limiting, and projections

# Singleton instance
static var _instance = null
static func get_instance() -> JSHQueryLanguage:
	if not _instance:
		_instance = JSHQueryLanguage.new()
	return _instance

# Reference to entity manager
var _entity_manager: JSHEntityManager

# Query operators
enum Operator {
	EQUALS,
	NOT_EQUALS,
	GREATER_THAN,
	LESS_THAN,
	GREATER_EQUAL,
	LESS_EQUAL,
	CONTAINS,
	NOT_CONTAINS,
	BEGINS_WITH,
	ENDS_WITH,
	IN,
	NOT_IN,
	EXISTS,
	NOT_EXISTS,
	MATCHES,
	AND,
	OR,
	NOT
}

# Query sort directions
enum SortDirection {
	ASCENDING,
	DESCENDING
}

# Operator symbols
const OPERATOR_SYMBOLS = {
	Operator.EQUALS: "==",
	Operator.NOT_EQUALS: "!=",
	Operator.GREATER_THAN: ">",
	Operator.LESS_THAN: "<",
	Operator.GREATER_EQUAL: ">=",
	Operator.LESS_EQUAL: "<=",
	Operator.CONTAINS: "contains",
	Operator.NOT_CONTAINS: "!contains",
	Operator.BEGINS_WITH: "startswith",
	Operator.ENDS_WITH: "endswith",
	Operator.IN: "in",
	Operator.NOT_IN: "!in",
	Operator.EXISTS: "exists",
	Operator.NOT_EXISTS: "!exists",
	Operator.MATCHES: "~=",
	Operator.AND: "&&",
	Operator.OR: "||",
	Operator.NOT: "!"
}

# Operator string to enum mapping
const OPERATOR_MAP = {
	"==": Operator.EQUALS,
	"=": Operator.EQUALS,
	"equals": Operator.EQUALS,
	"!=": Operator.NOT_EQUALS,
	"<>": Operator.NOT_EQUALS,
	"not_equals": Operator.NOT_EQUALS,
	">": Operator.GREATER_THAN,
	"greater_than": Operator.GREATER_THAN,
	"<": Operator.LESS_THAN,
	"less_than": Operator.LESS_THAN,
	">=": Operator.GREATER_EQUAL,
	"greater_equal": Operator.GREATER_EQUAL,
	"<=": Operator.LESS_EQUAL,
	"less_equal": Operator.LESS_EQUAL,
	"contains": Operator.CONTAINS,
	"!contains": Operator.NOT_CONTAINS,
	"not_contains": Operator.NOT_CONTAINS,
	"startswith": Operator.BEGINS_WITH,
	"begins_with": Operator.BEGINS_WITH,
	"endswith": Operator.ENDS_WITH,
	"ends_with": Operator.ENDS_WITH,
	"in": Operator.IN,
	"!in": Operator.NOT_IN,
	"not_in": Operator.NOT_IN,
	"exists": Operator.EXISTS,
	"!exists": Operator.NOT_EXISTS,
	"not_exists": Operator.NOT_EXISTS,
	"~=": Operator.MATCHES,
	"matches": Operator.MATCHES,
	"&&": Operator.AND,
	"and": Operator.AND,
	"||": Operator.OR,
	"or": Operator.OR,
	"!": Operator.NOT,
	"not": Operator.NOT
}

# Sort direction string to enum mapping
const SORT_DIRECTION_MAP = {
	"asc": SortDirection.ASCENDING,
	"ascending": SortDirection.ASCENDING,
	"desc": SortDirection.DESCENDING,
	"descending": SortDirection.DESCENDING
}

# Query inner class
class Query:
	var where: Dictionary = {}
	var sort: Array = []
	var limit: int = -1
	var offset: int = 0
	var select: Array = []
	var distinct: bool = false
	var group_by: Array = []
	var zone: String = ""
	var types: Array = []
	var tags: Array = []
	
	func _to_string() -> String:
		var parts = []
		
		if not types.is_empty():
			parts.append("TYPE(" + ", ".join(types) + ")")
		
		if not where.is_empty():
			parts.append("WHERE " + _condition_to_string(where))
		
		if not tags.is_empty():
			parts.append("TAGS(" + ", ".join(tags) + ")")
		
		if not zone.is_empty():
			parts.append("ZONE(" + zone + ")")
		
		if not sort.is_empty():
			var sort_parts = []
			for sort_item in sort:
				var direction = "ASC" if sort_item["direction"] == SortDirection.ASCENDING else "DESC"
				sort_parts.append(sort_item["property"] + " " + direction)
			parts.append("SORT BY " + ", ".join(sort_parts))
		
		if limit >= 0:
			parts.append("LIMIT " + str(limit))
		
		if offset > 0:
			parts.append("OFFSET " + str(offset))
		
		if not select.is_empty():
			parts.append("SELECT " + ", ".join(select))
		
		if distinct:
			parts.append("DISTINCT")
		
		if not group_by.is_empty():
			parts.append("GROUP BY " + ", ".join(group_by))
		
		return "QUERY " + " ".join(parts)
	
	# Helper function to convert condition to string
	func _condition_to_string(condition: Dictionary) -> String:
		if condition.has("operator"):
			var op = condition["operator"]
			
			# Logical operators (AND, OR, NOT)
			if op == Operator.AND or op == Operator.OR:
				var sub_conditions = []
				for subcond in condition["conditions"]:
					sub_conditions.append(_condition_to_string(subcond))
				
				var op_str = OPERATOR_SYMBOLS[op]
				return "(" + (" " + op_str + " ").join(sub_conditions) + ")"
			
			elif op == Operator.NOT:
				return OPERATOR_SYMBOLS[op] + "(" + _condition_to_string(condition["condition"]) + ")"
			
			# Property operators
			else:
				var prop = condition["property"]
				var op_str = OPERATOR_SYMBOLS[op]
				
				# Special cases for operators without values
				if op == Operator.EXISTS or op == Operator.NOT_EXISTS:
					return prop + " " + op_str
				
				var value = condition["value"]
				if value is String:
					value = "\"" + value + "\""
				elif value is Array:
					var value_strs = []
					for val in value:
						if val is String:
							value_strs.append("\"" + val + "\"")
						else:
							value_strs.append(str(val))
					value = "[" + ", ".join(value_strs) + "]"
				
				return prop + " " + op_str + " " + str(value)
		
		return "{invalid condition}"

func _init():
	# Get entity manager reference
	_entity_manager = JSHEntityManager.get_instance()

# Create a new query
func create_query() -> Query:
	return Query.new()

# Execute a query and return matching entities
func execute_query(query: Query) -> Array:
	# Get all entities, or entities from specific zone if specified
	var entities = []
	
	if not query.zone.is_empty():
		var spatial_manager = JSHSpatialManager.get_instance()
		if spatial_manager:
			entities = spatial_manager.get_entities_in_zone(query.zone)
		else:
			push_warning("SpatialManager not available but zone specified in query")
			entities = _entity_manager.get_all_entities()
	else:
		entities = _entity_manager.get_all_entities()
	
	# Filter by types if specified
	if not query.types.is_empty():
		entities = entities.filter(func(entity): 
			return entity.entity_type in query.types
		)
	
	# Filter by tags if specified
	if not query.tags.is_empty():
		entities = entities.filter(func(entity):
			for tag in query.tags:
				if not entity.has_tag(tag):
					return false
			return true
		)
	
	# Apply where condition if specified
	if not query.where.is_empty():
		entities = entities.filter(func(entity):
			return _evaluate_condition(query.where, entity)
		)
	
	# Apply sorting if specified
	if not query.sort.is_empty():
		for sort_item in query.sort:
			var property_name = sort_item["property"]
			var direction = sort_item["direction"]
			
			entities.sort_custom(func(a, b):
				var a_value = a.get_property(property_name)
				var b_value = b.get_property(property_name)
				
				# Handle null values
				if a_value == null and b_value == null:
					return 0
				elif a_value == null:
					return 1 if direction == SortDirection.ASCENDING else -1
				elif b_value == null:
					return -1 if direction == SortDirection.ASCENDING else 1
				
				# Compare values based on direction
				if direction == SortDirection.ASCENDING:
					return a_value < b_value
				else:
					return a_value > b_value
			)
	
	# Apply offset if specified
	if query.offset > 0:
		entities = entities.slice(min(query.offset, entities.size()))
	
	# Apply limit if specified
	if query.limit >= 0 and query.limit < entities.size():
		entities = entities.slice(0, query.limit)
	
	# Apply projection if specified
	if not query.select.is_empty():
		var result = []
		for entity in entities:
			var item = {}
			for prop in query.select:
				if prop == "entity_id":
					item[prop] = entity.entity_id
				elif prop == "entity_type":
					item[prop] = entity.entity_type
				elif prop == "position":
					item[prop] = entity.position
				elif prop == "complexity":
					item[prop] = entity.complexity
				else:
					item[prop] = entity.get_property(prop)
			result.append(item)
		return result
	
	# Apply distinct if specified
	if query.distinct:
		var distinct_entities = []
		var seen_ids = {}
		
		for entity in entities:
			if not seen_ids.has(entity.entity_id):
				distinct_entities.append(entity)
				seen_ids[entity.entity_id] = true
		
		return distinct_entities
	
	# Apply group by if specified - note: this changes the return format
	if not query.group_by.is_empty():
		var groups = {}
		
		for entity in entities:
			var group_key = ""
			for prop in query.group_by:
				var value = entity.get_property(prop)
				group_key += str(value) + "|||"
			
			if not groups.has(group_key):
				groups[group_key] = []
			
			groups[group_key].append(entity)
		
		return groups.values()
	
	return entities

# Parse a query string into a Query object
func parse_query_string(query_string: String) -> Query:
	var query = Query.new()
	
	# Tokenize the query string
	var tokens = _tokenize_query_string(query_string)
	var i = 0
	
	while i < tokens.size():
		var token = tokens[i].to_upper()
		
		match token:
			"TYPE", "TYPES":
				i += 1
				if i < tokens.size() and tokens[i] == "(":
					i += 1
					var types = []
					while i < tokens.size() and tokens[i] != ")":
						if tokens[i] != ",":
							types.append(tokens[i])
						i += 1
					query.types = types
			
			"WHERE":
				i += 1
				var condition_tokens = []
				var paren_count = 0
				
				while i < tokens.size():
					var next_token = tokens[i]
					
					# Count parentheses to handle nested conditions
					if next_token == "(":
						paren_count += 1
					elif next_token == ")":
						paren_count -= 1
					
					# Stop at the next clause if we're at the top level
					if paren_count == 0 and _is_clause_keyword(next_token.to_upper()):
						break
					
					condition_tokens.append(next_token)
					i += 1
				
				# Parse the condition tokens
				query.where = _parse_condition_tokens(condition_tokens)
				continue # Skip incrementing i since we already advanced
			
			"TAGS":
				i += 1
				if i < tokens.size() and tokens[i] == "(":
					i += 1
					var tags = []
					while i < tokens.size() and tokens[i] != ")":
						if tokens[i] != ",":
							tags.append(tokens[i])
						i += 1
					query.tags = tags
			
			"ZONE":
				i += 1
				if i < tokens.size() and tokens[i] == "(":
					i += 1
					if i < tokens.size() and tokens[i] != ")":
						query.zone = tokens[i]
					i += 1  # Skip closing parenthesis
			
			"SORT", "ORDER":
				i += 1
				if i < tokens.size() and tokens[i].to_upper() == "BY":
					i += 1
					while i < tokens.size() and not _is_clause_keyword(tokens[i].to_upper()):
						var property_name = tokens[i]
						var direction = SortDirection.ASCENDING
						
						i += 1
						if i < tokens.size() and (tokens[i].to_upper() == "ASC" or tokens[i].to_upper() == "DESC"):
							direction = SortDirection.ASCENDING if tokens[i].to_upper() == "ASC" else SortDirection.DESCENDING
							i += 1
						
						query.sort.append({
							"property": property_name,
							"direction": direction
						})
						
						if i < tokens.size() and tokens[i] == ",":
							i += 1
						else:
							break
				}
			
			"LIMIT":
				i += 1
				if i < tokens.size():
					query.limit = int(tokens[i])
			
			"OFFSET":
				i += 1
				if i < tokens.size():
					query.offset = int(tokens[i])
			
			"SELECT":
				i += 1
				var properties = []
				while i < tokens.size() and not _is_clause_keyword(tokens[i].to_upper()):
					if tokens[i] != ",":
						properties.append(tokens[i])
					i += 1
					if i >= tokens.size() or _is_clause_keyword(tokens[i].to_upper()):
						break
				query.select = properties
				continue # Skip incrementing i since we already advanced
			
			"DISTINCT":
				query.distinct = true
			
			"GROUP", "GROUPBY":
				if token == "GROUP":
					i += 1
					if i < tokens.size() and tokens[i].to_upper() != "BY":
						push_error("Expected 'BY' after 'GROUP'")
						return query
				
				i += 1
				var group_properties = []
				while i < tokens.size() and not _is_clause_keyword(tokens[i].to_upper()):
					if tokens[i] != ",":
						group_properties.append(tokens[i])
					i += 1
					if i >= tokens.size() or _is_clause_keyword(tokens[i].to_upper()):
						break
				query.group_by = group_properties
				continue # Skip incrementing i since we already advanced
		
		i += 1
	
	return query

# Add a where condition to a query
func add_where_condition(query: Query, property: String, operator, value) -> Query:
	var condition = {
		"property": property,
		"operator": _normalize_operator(operator),
		"value": value
	}
	
	if query.where.is_empty():
		query.where = condition
	else:
		query.where = {
			"operator": Operator.AND,
			"conditions": [query.where, condition]
		}
	
	return query

# Add an AND condition to a query
func add_and_condition(query: Query, property: String, operator, value) -> Query:
	return add_where_condition(query, property, operator, value)

# Add an OR condition to a query
func add_or_condition(query: Query, property: String, operator, value) -> Query:
	var condition = {
		"property": property,
		"operator": _normalize_operator(operator),
		"value": value
	}
	
	if query.where.is_empty():
		query.where = condition
	else:
		if query.where.has("operator") and query.where["operator"] == Operator.OR:
			# If the top level is already an OR, just add to it
			query.where["conditions"].append(condition)
		else:
			# Otherwise, create a new OR condition
			query.where = {
				"operator": Operator.OR,
				"conditions": [query.where, condition]
			}
	
	return query

# Add a NOT condition to a query
func add_not_condition(query: Query, property: String, operator, value) -> Query:
	var condition = {
		"property": property,
		"operator": _normalize_operator(operator),
		"value": value
	}
	
	var not_condition = {
		"operator": Operator.NOT,
		"condition": condition
	}
	
	if query.where.is_empty():
		query.where = not_condition
	else:
		query.where = {
			"operator": Operator.AND,
			"conditions": [query.where, not_condition]
		}
	
	return query

# Add a sort clause to a query
func add_sort(query: Query, property: String, direction = SortDirection.ASCENDING) -> Query:
	query.sort.append({
		"property": property,
		"direction": direction
	})
	
	return query

# Add a selection to a query
func add_select(query: Query, properties: Array) -> Query:
	for property in properties:
		if not property in query.select:
			query.select.append(property)
	
	return query

# Set the limit for a query
func set_limit(query: Query, limit: int) -> Query:
	query.limit = limit
	return query

# Set the offset for a query
func set_offset(query: Query, offset: int) -> Query:
	query.offset = offset
	return query

# Set distinct flag for a query
func set_distinct(query: Query, distinct: bool = true) -> Query:
	query.distinct = distinct
	return query

# Add group by to a query
func add_group_by(query: Query, properties: Array) -> Query:
	for property in properties:
		if not property in query.group_by:
			query.group_by.append(property)
	
	return query

# Add entity types filter to a query
func add_types(query: Query, types: Array) -> Query:
	for type_name in types:
		if not type_name in query.types:
			query.types.append(type_name)
	
	return query

# Add tags filter to a query
func add_tags(query: Query, tags: Array) -> Query:
	for tag in tags:
		if not tag in query.tags:
			query.tags.append(tag)
	
	return query

# Set zone filter for a query
func set_zone(query: Query, zone: String) -> Query:
	query.zone = zone
	return query

# Evaluate a condition against an entity
func _evaluate_condition(condition: Dictionary, entity: JSHUniversalEntity) -> bool:
	# Handle logical operators first
	if condition.has("operator"):
		var op = condition["operator"]
		
		if op == Operator.AND:
			var conditions = condition["conditions"]
			for subcond in conditions:
				if not _evaluate_condition(subcond, entity):
					return false
			return true
		
		elif op == Operator.OR:
			var conditions = condition["conditions"]
			for subcond in conditions:
				if _evaluate_condition(subcond, entity):
					return true
			return false
		
		elif op == Operator.NOT:
			var subcond = condition["condition"]
			return not _evaluate_condition(subcond, entity)
		
		# Handle property operators
		else:
			var property_name = condition["property"]
			
			# Special cases for existence checks
			if op == Operator.EXISTS:
				return entity.has_property(property_name)
			
			if op == Operator.NOT_EXISTS:
				return not entity.has_property(property_name)
			
			# For all other operators, we need a property value
			var property_value = null
			
			# Handle special properties
			if property_name == "entity_id":
				property_value = entity.entity_id
			elif property_name == "entity_type":
				property_value = entity.entity_type
			elif property_name == "position":
				property_value = entity.position
			elif property_name == "complexity":
				property_value = entity.complexity
			else:
				# Get regular property value
				property_value = entity.get_property(property_name)
			
			# If property doesn't exist (and we're not checking for existence), condition fails
			if property_value == null and op != Operator.NOT_EXISTS:
				return false
			
			var compare_value = condition["value"]
			
			# Compare based on operator
			match op:
				Operator.EQUALS:
					return property_value == compare_value
				
				Operator.NOT_EQUALS:
					return property_value != compare_value
				
				Operator.GREATER_THAN:
					return property_value > compare_value
				
				Operator.LESS_THAN:
					return property_value < compare_value
				
				Operator.GREATER_EQUAL:
					return property_value >= compare_value
				
				Operator.LESS_EQUAL:
					return property_value <= compare_value
				
				Operator.CONTAINS:
					if property_value is String:
						return property_value.contains(str(compare_value))
					elif property_value is Array:
						return compare_value in property_value
					return false
				
				Operator.NOT_CONTAINS:
					if property_value is String:
						return not property_value.contains(str(compare_value))
					elif property_value is Array:
						return not compare_value in property_value
					return true
				
				Operator.BEGINS_WITH:
					if property_value is String:
						return property_value.begins_with(str(compare_value))
					return false
				
				Operator.ENDS_WITH:
					if property_value is String:
						return property_value.ends_with(str(compare_value))
					return false
				
				Operator.IN:
					if compare_value is Array:
						return property_value in compare_value
					return false
				
				Operator.NOT_IN:
					if compare_value is Array:
						return not property_value in compare_value
					return true
				
				Operator.MATCHES:
					if property_value is String and compare_value is String:
						var regex = RegEx.new()
						var error = regex.compile(compare_value)
						if error == OK:
							return regex.search(property_value) != null
					return false
	
	return false

# Tokenize a query string
func _tokenize_query_string(query_string: String) -> Array:
	var tokens = []
	var current_token = ""
	var in_string = false
	var i = 0
	
	while i < query_string.length():
		var char = query_string[i]
		
		# Handle strings (quoted values)
		if char == '"' or char == "'":
			if in_string and query_string[i-1] != '\\':
				# End of string
				tokens.append(current_token)
				current_token = ""
				in_string = false
			elif not in_string:
				# Start of string
				if not current_token.is_empty():
					tokens.append(current_token)
					current_token = ""
				in_string = true
			else:
				# Escaped quote within string
				current_token += char
		
		# Handle whitespace (unless in string)
		elif char.strip_edges().is_empty() and not in_string:
			if not current_token.is_empty():
				tokens.append(current_token)
				current_token = ""
		
		# Handle special characters (unless in string)
		elif not in_string and (char in "()[]{},."):
			if not current_token.is_empty():
				tokens.append(current_token)
				current_token = ""
			tokens.append(char)
		
		# Handle regular characters
		else:
			current_token += char
		
		i += 1
	
	# Add any remaining token
	if not current_token.is_empty():
		tokens.append(current_token)
	
	return tokens

# Parse condition tokens into a condition structure
func _parse_condition_tokens(tokens: Array) -> Dictionary:
	if tokens.is_empty():
		return {}
	
	# Handle parenthesized expressions
	if tokens[0] == "(" and tokens[-1] == ")":
		return _parse_condition_tokens(tokens.slice(1, -1))
	
	# Check for AND conditions
	var and_indices = []
	var paren_count = 0
	
	for i in range(tokens.size()):
		var token = tokens[i]
		
		if token == "(":
			paren_count += 1
		elif token == ")":
			paren_count -= 1
		elif (token.to_upper() == "AND" or token == "&&") and paren_count == 0:
			and_indices.append(i)
	
	if not and_indices.is_empty():
		var conditions = []
		var start_idx = 0
		
		for idx in and_indices:
			conditions.append(_parse_condition_tokens(tokens.slice(start_idx, idx)))
			start_idx = idx + 1
		
		conditions.append(_parse_condition_tokens(tokens.slice(start_idx)))
		
		return {
			"operator": Operator.AND,
			"conditions": conditions
		}
	
	# Check for OR conditions
	var or_indices = []
	paren_count = 0
	
	for i in range(tokens.size()):
		var token = tokens[i]
		
		if token == "(":
			paren_count += 1
		elif token == ")":
			paren_count -= 1
		elif (token.to_upper() == "OR" or token == "||") and paren_count == 0:
			or_indices.append(i)
	
	if not or_indices.is_empty():
		var conditions = []
		var start_idx = 0
		
		for idx in or_indices:
			conditions.append(_parse_condition_tokens(tokens.slice(start_idx, idx)))
			start_idx = idx + 1
		
		conditions.append(_parse_condition_tokens(tokens.slice(start_idx)))
		
		return {
			"operator": Operator.OR,
			"conditions": conditions
		}
	
	# Check for NOT conditions
	if tokens[0].to_upper() == "NOT" or tokens[0] == "!":
		return {
			"operator": Operator.NOT,
			"condition": _parse_condition_tokens(tokens.slice(1))
		}
	
	# Parse property conditions
	if tokens.size() >= 3:
		var property_name = tokens[0]
		var op_token = tokens[1]
		
		if OPERATOR_MAP.has(op_token.to_lower()):
			var operator = OPERATOR_MAP[op_token.to_lower()]
			
			# Handle operators that don't need values
			if operator == Operator.EXISTS or operator == Operator.NOT_EXISTS:
				return {
					"property": property_name,
					"operator": operator
				}
			
			# Parse value
			var value = null
			
			if tokens.size() > 2:
				if tokens[2] == "[" and tokens[-1] == "]":
					# Parse array value
					var array_values = []
					var i = 3
					
					while i < tokens.size() - 1:
						if tokens[i] != ",":
							array_values.append(_parse_value(tokens[i]))
						i += 1
					
					value = array_values
				else:
					# Parse single value
					value = _parse_value(tokens[2])
			
			return {
				"property": property_name,
				"operator": operator,
				"value": value
			}
	}
	
	# Couldn't parse the condition
	push_error("Invalid condition syntax: " + " ".join(tokens))
	return {}

# Parse a value token
func _parse_value(token: String):
	# Try to parse as number
	if token.is_valid_int():
		return int(token)
	elif token.is_valid_float():
		return float(token)
	
	# Handle booleans
	if token.to_lower() == "true":
		return true
	elif token.to_lower() == "false":
		return false
	
	# Handle null
	if token.to_lower() == "null":
		return null
	
	# Remove quotes from strings
	if (token.begins_with("\"") and token.ends_with("\"")) or (token.begins_with("'") and token.ends_with("'")):
		return token.substr(1, token.length() - 2)
	
	# Return as is (likely a string without quotes)
	return token

# Check if a token is a clause keyword
func _is_clause_keyword(token: String) -> bool:
	const KEYWORDS = [
		"WHERE", "TYPE", "TYPES", "TAGS", "ZONE", 
		"SORT", "ORDER", "LIMIT", "OFFSET", 
		"SELECT", "DISTINCT", "GROUP", "GROUPBY"
	]
	
	return token in KEYWORDS

# Normalize operator to enum
func _normalize_operator(operator) -> int:
	if operator is int:
		return operator
	
	if operator is String and OPERATOR_MAP.has(operator.to_lower()):
		return OPERATOR_MAP[operator.to_lower()]
	
	push_error("Invalid operator: " + str(operator))
	return Operator.EQUALS