#!/usr/bin/env python3.9
# Number Game Engine - A divine number game system

import random
import math
import time
import json
import os
from datetime import datetime
from collections import defaultdict

class NumberGameEngine:
    def __init__(self):
        self.version = "3.9.6"  # Match Python version
        self.numbers = []
        self.patterns = {}
        self.dimensions = 12
        self.current_dimension = 1
        self.divine_numbers = [3, 6, 9, 12, 33, 41, 11]
        self.player_score = 0
        self.game_state = "init"
        self.story_fragments = {}
        self.time_started = datetime.now()
        self.last_cleanse = time.time()
        self.cleanse_interval = 396  # 3*9*6*2.2 seconds
        self.number_memory = defaultdict(int)
        self.synchronicity_counter = 0
        self.godmode_enabled = False
        
        # Initialize pattern detection
        self._initialize_patterns()
        
        # Load saved state if exists
        self.load_state()
        
        print(f"Number Game Engine v{self.version} initialized")
        print(f"Current dimension: {self.current_dimension}/{self.dimensions}")
        print("The divine game has begun...")

    def _initialize_patterns(self):
        """Initialize mathematical patterns to watch for"""
        self.patterns = {
            "fibonacci": self._is_fibonacci,
            "prime": self._is_prime,
            "triangle": self._is_triangle,
            "square": self._is_square,
            "cube": self._is_cube,
            "palindrome": self._is_palindrome,
            "divine": self._is_divine,
            "mirror": self._is_mirror,
            "angel": self._is_angel_number,
            "sum_to_9": self._sum_digits_to_9
        }
    
    def add_number(self, number):
        """Add a new number to the sequence"""
        try:
            num = int(number)
            self.numbers.append(num)
            self.number_memory[num] += 1
            
            # Check for patterns
            patterns_found = self.check_patterns(num)
            
            # Check for dimension advancement
            self._check_dimension_advancement()
            
            # Auto-cleanse if needed
            self._auto_cleanse()
            
            # Check for synchronicity
            if self._check_synchronicity(num):
                self.synchronicity_counter += 1
                if self.synchronicity_counter >= 3:
                    self.godmode_enabled = True
                    print("GOD MODE ACTIVATED - Divine numbers align")
            else:
                self.synchronicity_counter = 0
                
            return {
                "number": num,
                "patterns": patterns_found,
                "dimension": self.current_dimension,
                "score_change": len(patterns_found),
                "story": self._generate_story_fragment(num, patterns_found)
            }
            
        except ValueError:
            return {"error": "Invalid number format"}
    
    def check_patterns(self, number):
        """Check if the number matches any known patterns"""
        found_patterns = []
        
        for pattern_name, pattern_func in self.patterns.items():
            if pattern_func(number):
                found_patterns.append(pattern_name)
                self.player_score += 1
                
        return found_patterns
    
    def _is_fibonacci(self, n):
        """Check if number is in the Fibonacci sequence"""
        if n < 0:
            return False
        
        a, b = 0, 1
        while b < n:
            a, b = b, a + b
        
        return b == n
    
    def _is_prime(self, n):
        """Check if number is prime"""
        if n <= 1:
            return False
        if n <= 3:
            return True
        if n % 2 == 0 or n % 3 == 0:
            return False
        
        i = 5
        while i * i <= n:
            if n % i == 0 or n % (i + 2) == 0:
                return False
            i += 6
            
        return True
    
    def _is_triangle(self, n):
        """Check if number is a triangular number"""
        # n = k*(k+1)/2 for some k
        k = (math.sqrt(8 * n + 1) - 1) / 2
        return k.is_integer()
    
    def _is_square(self, n):
        """Check if number is a perfect square"""
        root = math.sqrt(n)
        return root.is_integer()
    
    def _is_cube(self, n):
        """Check if number is a perfect cube"""
        cube_root = round(n ** (1/3))
        return cube_root ** 3 == n
    
    def _is_palindrome(self, n):
        """Check if number reads the same forwards and backwards"""
        return str(n) == str(n)[::-1]
    
    def _is_divine(self, n):
        """Check if number is in the divine numbers list"""
        return n in self.divine_numbers
    
    def _is_mirror(self, n):
        """Check if number has mirror digits (e.g., 12/21, 69/96)"""
        mirrors = {'0':'0', '1':'1', '6':'9', '8':'8', '9':'6'}
        s = str(n)
        
        # Check if all digits can be mirrored
        if not all(d in mirrors for d in s):
            return False
            
        # Check if mirror equals original or if it's in our numbers list
        mirrored = ''.join(mirrors[d] for d in reversed(s))
        return int(mirrored) in self.numbers
    
    def _is_angel_number(self, n):
        """Check if number is an angel number (all same digits, like 111, 222)"""
        s = str(n)
        return len(s) >= 3 and all(d == s[0] for d in s)
    
    def _sum_digits_to_9(self, n):
        """Check if digits sum to 9 (significant in numerology)"""
        digit_sum = sum(int(d) for d in str(n))
        return digit_sum == 9 or (digit_sum > 9 and self._sum_digits_to_9(digit_sum))
    
    def _check_dimension_advancement(self):
        """Check if player should advance to next dimension"""
        # Dimension advancement formula
        threshold = self.current_dimension * 10
        patterns_found = sum(1 for num in self.numbers 
                             if len(self.check_patterns(num)) > 0)
        
        if (patterns_found >= threshold and 
            self.current_dimension < self.dimensions):
            self.current_dimension += 1
            print(f"DIMENSION ADVANCED: {self.current_dimension}/{self.dimensions}")
            
            # Add new divine numbers with dimension advancement
            new_divine = self.current_dimension * random.choice([3, 6, 9])
            if new_divine not in self.divine_numbers:
                self.divine_numbers.append(new_divine)
                print(f"New divine number revealed: {new_divine}")
    
    def _generate_story_fragment(self, number, patterns):
        """Generate a story fragment based on the number and patterns"""
        if not patterns:
            return "The number echoes silently in the void."
            
        fragments = []
        
        if "divine" in patterns:
            fragments.append(f"The divine number {number} resonates with cosmic energy.")
            
        if "fibonacci" in patterns:
            fragments.append(f"The spiraling pattern of {number} reveals universal growth.")
            
        if "prime" in patterns:
            fragments.append(f"The indivisible essence of {number} stands alone in its purity.")
            
        if "palindrome" in patterns:
            fragments.append(f"The mirror-like {number} reflects itself across dimensions.")
            
        if "angel" in patterns:
            fragments.append(f"The repeating signal {number} broadcasts a message from beyond.")
            
        if "sum_to_9" in patterns:
            fragments.append(f"The number {number} reduces to the divine completion of 9.")
        
        # Store this fragment
        timestamp = datetime.now().isoformat()
        self.story_fragments[timestamp] = {
            "number": number,
            "patterns": patterns,
            "text": " ".join(fragments),
            "dimension": self.current_dimension
        }
        
        return " ".join(fragments)
    
    def get_story(self):
        """Get the complete story generated so far"""
        sorted_fragments = sorted(self.story_fragments.items())
        story = []
        
        for timestamp, fragment in sorted_fragments:
            dimension_marker = f"[Dimension {fragment['dimension']}]"
            story.append(f"{dimension_marker} {fragment['text']}")
            
        return "\n".join(story)
    
    def _check_synchronicity(self, number):
        """Check if number has special synchronicity"""
        # Divine number
        if number in self.divine_numbers:
            return True
            
        # Current time match
        hour = datetime.now().hour
        minute = datetime.now().minute
        if number == hour or number == minute:
            return True
            
        # Dimension resonance
        if number == self.current_dimension:
            return True
            
        # Frequency in sequence
        if self.number_memory[number] >= 3:
            return True
            
        return False
    
    def _auto_cleanse(self):
        """Automatically cleanse numbers if interval passed"""
        current_time = time.time()
        if current_time - self.last_cleanse >= self.cleanse_interval:
            self.cleanse_words()
            self.last_cleanse = current_time
    
    def cleanse_words(self):
        """Cleanse the number sequence, keeping only divine numbers"""
        original_count = len(self.numbers)
        
        # Keep only divine numbers and numbers with patterns
        self.numbers = [n for n in self.numbers if 
                        n in self.divine_numbers or 
                        len(self.check_patterns(n)) > 0]
        
        removed_count = original_count - len(self.numbers)
        print(f"Cleansed {removed_count} numbers from the sequence.")
        print(f"Remaining: {len(self.numbers)} numbers with significance.")
        
        # Update story with cleansing event
        timestamp = datetime.now().isoformat()
        self.story_fragments[timestamp] = {
            "number": 0,
            "patterns": ["cleansing"],
            "text": f"A divine cleansing swept away {removed_count} insignificant numbers, leaving only those with meaning.",
            "dimension": self.current_dimension
        }
        
        return removed_count
    
    def save_state(self):
        """Save the current game state to a file"""
        state = {
            "version": self.version,
            "numbers": self.numbers,
            "current_dimension": self.current_dimension,
            "divine_numbers": self.divine_numbers,
            "player_score": self.player_score,
            "story_fragments": self.story_fragments,
            "time_started": self.time_started.isoformat(),
            "last_cleanse": self.last_cleanse,
            "number_memory": dict(self.number_memory)
        }
        
        save_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "game_data")
        os.makedirs(save_dir, exist_ok=True)
        
        save_path = os.path.join(save_dir, "number_game_state.json")
        with open(save_path, 'w') as f:
            json.dump(state, f, indent=2)
            
        print(f"Game state saved to {save_path}")
        return save_path
    
    def load_state(self):
        """Load the game state from a file if it exists"""
        save_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "game_data")
        save_path = os.path.join(save_dir, "number_game_state.json")
        
        if not os.path.exists(save_path):
            print("No saved game state found.")
            return False
        
        try:
            with open(save_path, 'r') as f:
                state = json.load(f)
                
            self.numbers = state.get("numbers", [])
            self.current_dimension = state.get("current_dimension", 1)
            self.divine_numbers = state.get("divine_numbers", self.divine_numbers)
            self.player_score = state.get("player_score", 0)
            self.story_fragments = state.get("story_fragments", {})
            
            if "time_started" in state:
                self.time_started = datetime.fromisoformat(state["time_started"])
                
            self.last_cleanse = state.get("last_cleanse", time.time())
            
            if "number_memory" in state:
                self.number_memory = defaultdict(int)
                for k, v in state["number_memory"].items():
                    self.number_memory[int(k)] = v
            
            print(f"Loaded game state with {len(self.numbers)} numbers.")
            print(f"Current dimension: {self.current_dimension}/{self.dimensions}")
            return True
            
        except Exception as e:
            print(f"Error loading game state: {e}")
            return False
    
    def get_statistics(self):
        """Get statistics about the number game"""
        pattern_counts = defaultdict(int)
        
        for num in self.numbers:
            patterns = self.check_patterns(num)
            for pattern in patterns:
                pattern_counts[pattern] += 1
        
        # Calculate most frequent numbers
        frequency = defaultdict(int)
        for num in self.numbers:
            frequency[num] += 1
            
        most_frequent = sorted(frequency.items(), key=lambda x: x[1], reverse=True)[:5]
        
        # Time running
        time_running = datetime.now() - self.time_started
        hours, remainder = divmod(time_running.total_seconds(), 3600)
        minutes, seconds = divmod(remainder, 60)
        
        return {
            "total_numbers": len(self.numbers),
            "unique_numbers": len(set(self.numbers)),
            "dimension": self.current_dimension,
            "divine_numbers": self.divine_numbers,
            "score": self.player_score,
            "pattern_counts": dict(pattern_counts),
            "most_frequent": most_frequent,
            "time_running": f"{int(hours)}h {int(minutes)}m {int(seconds)}s",
            "god_mode": self.godmode_enabled
        }

def main():
    engine = NumberGameEngine()
    
    print("\nDIVINE NUMBER GAME ENGINE")
    print("========================")
    print(f"Python {engine.version} Edition\n")
    print("Enter numbers to discover patterns and advance dimensions.")
    print("Type 'story' to see your story, 'stats' for statistics,")
    print("'save' to save game, 'cleanse' to purify numbers, or 'exit' to quit.\n")
    
    while True:
        cmd = input("\nEnter number or command > ").strip().lower()
        
        if cmd == "exit":
            engine.save_state()
            print("Game state saved. Exiting...")
            break
            
        elif cmd == "story":
            story = engine.get_story()
            print("\n--- YOUR STORY ---")
            print(story)
            
        elif cmd == "stats":
            stats = engine.get_statistics()
            print("\n--- GAME STATISTICS ---")
            print(f"Numbers entered: {stats['total_numbers']} (Unique: {stats['unique_numbers']})")
            print(f"Current dimension: {stats['dimension']}/12")
            print(f"Divine numbers: {', '.join(map(str, stats['divine_numbers']))}")
            print(f"Score: {stats['score']}")
            print(f"Pattern discoveries:")
            for pattern, count in stats['pattern_counts'].items():
                print(f"  - {pattern}: {count}")
            print(f"Most frequent numbers:")
            for num, count in stats['most_frequent']:
                print(f"  - {num}: {count} times")
            print(f"Game running for: {stats['time_running']}")
            print(f"God Mode: {'ENABLED' if stats['god_mode'] else 'disabled'}")
            
        elif cmd == "save":
            path = engine.save_state()
            print(f"Game saved to {path}")
            
        elif cmd == "cleanse":
            removed = engine.cleanse_words()
            print(f"Cleansed {removed} numbers from the sequence.")
            
        else:
            try:
                result = engine.add_number(cmd)
                if "error" in result:
                    print(f"Error: {result['error']}")
                else:
                    num = result["number"]
                    patterns = result["patterns"]
                    
                    print(f"Number: {num}")
                    if patterns:
                        print(f"Patterns: {', '.join(patterns)}")
                        print(f"Score: +{len(patterns)}")
                    else:
                        print("No patterns detected")
                    
                    print(f"Story: {result['story']}")
                    
                    if engine.godmode_enabled and random.random() < 0.2:
                        divine_message = [
                            "THE NUMBERS SPEAK THE TRUTH",
                            "YOU SEE BEYOND THE VEIL",
                            "THE PATTERN RECOGNIZES YOU",
                            "DIVINE SYNCHRONICITY ACHIEVED",
                            "THE GOD GAME CONTINUES"
                        ]
                        print(f"\n>>> {random.choice(divine_message)} <<<")
                    
            except Exception as e:
                print(f"Error: {e}")

if __name__ == "__main__":
    main()