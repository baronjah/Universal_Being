#!/usr/bin/env python3
"""
Text Splicer and Unwrapper

This module provides functionality for text splicing, cutting, and unwrapping
with configurable limits based on time of day and other parameters. It can
process text in various ways including segmentation, transformation, and
dream-time based processing.
"""

import os
import re
import time
import json
import random
import datetime
from typing import List, Dict, Union, Optional, Tuple, Any, Callable

# Constants for time-based processing
TIME_LIMITS = {
    "morning": {"start": 7, "end": 12, "max_segments": 7},
    "afternoon": {"start": 12, "end": 17, "max_segments": 8},
    "evening": {"start": 17, "end": 22, "max_segments": 9},
    "night": {"start": 22, "end": 7, "max_segments": 10}
}

# Dream time periods (when text processing is more creative)
DREAM_TIMES = [
    {"start": "10:00", "end": "11:30"},
    {"start": "15:00", "end": "16:30"},
    {"start": "20:00", "end": "22:00"}
]

# Default text processing modes
DEFAULT_MODES = ["cut", "splice", "unwrap", "dream", "fold"]

class TextFragment:
    """Represents a processed fragment of text with metadata"""
    
    def __init__(self, 
                content: str,
                index: int = 0,
                type: str = "standard",
                timestamp: Optional[float] = None,
                tags: Optional[List[str]] = None,
                parent_id: Optional[str] = None):
        """Initialize a text fragment"""
        self.content = content
        self.index = index
        self.type = type
        self.timestamp = timestamp or time.time()
        self.tags = tags or []
        self.parent_id = parent_id
        self.id = self._generate_id()
        self.metadata = {}
    
    def _generate_id(self) -> str:
        """Generate a unique ID for this fragment"""
        return f"{int(self.timestamp)}-{self.index}-{hash(self.content) % 10000}"
    
    def add_tag(self, tag: str) -> None:
        """Add a tag to this fragment"""
        if tag not in self.tags:
            self.tags.append(tag)
    
    def is_dream_fragment(self) -> bool:
        """Check if this is a dream fragment"""
        return self.type == "dream" or "dream" in self.tags
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "id": self.id,
            "content": self.content,
            "index": self.index,
            "type": self.type,
            "timestamp": self.timestamp,
            "tags": self.tags,
            "parent_id": self.parent_id,
            "metadata": self.metadata
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'TextFragment':
        """Create a TextFragment from a dictionary"""
        fragment = cls(
            content=data["content"],
            index=data["index"],
            type=data["type"],
            timestamp=data["timestamp"],
            tags=data["tags"],
            parent_id=data["parent_id"]
        )
        fragment.id = data["id"]
        fragment.metadata = data.get("metadata", {})
        return fragment
    
    def __str__(self) -> str:
        """String representation"""
        return f"[{self.type}] {self.content[:30]}..." if len(self.content) > 30 else self.content

class TextSplicer:
    """Main class for text splicing, cutting, and unwrapping"""
    
    def __init__(self, 
                max_segments: Optional[int] = None,
                modes: Optional[List[str]] = None,
                dream_mode_enabled: bool = True,
                time_limits: Optional[Dict[str, Dict[str, Any]]] = None,
                dream_times: Optional[List[Dict[str, str]]] = None,
                output_dir: Optional[str] = None):
        """Initialize the text splicer"""
        self.max_segments = max_segments  # If None, will use time-based limits
        self.modes = modes or DEFAULT_MODES.copy()
        self.dream_mode_enabled = dream_mode_enabled
        self.time_limits = time_limits or TIME_LIMITS.copy()
        self.dream_times = dream_times or DREAM_TIMES.copy()
        self.output_dir = output_dir or os.path.join(os.path.expanduser("~"), "text_splicer_output")
        self.fragments: List[TextFragment] = []
        self.history: List[Dict[str, Any]] = []
        self.processors: Dict[str, Callable] = {}
        
        # Create output directory if it doesn't exist
        os.makedirs(self.output_dir, exist_ok=True)
        
        # Register default processors
        self._register_default_processors()
    
    def _register_default_processors(self) -> None:
        """Register default text processors"""
        self.processors["cut"] = self._cut_processor
        self.processors["splice"] = self._splice_processor
        self.processors["unwrap"] = self._unwrap_processor
        self.processors["dream"] = self._dream_processor
        self.processors["fold"] = self._fold_processor
    
    def _get_current_time_period(self) -> str:
        """Get the current time period (morning, afternoon, evening, night)"""
        now = datetime.datetime.now()
        hour = now.hour
        
        if 7 <= hour < 12:
            return "morning"
        elif 12 <= hour < 17:
            return "afternoon"
        elif 17 <= hour < 22:
            return "evening"
        else:
            return "night"
    
    def _get_max_segments(self) -> int:
        """Get the maximum number of segments based on time of day"""
        if self.max_segments is not None:
            return self.max_segments
        
        time_period = self._get_current_time_period()
        return self.time_limits[time_period]["max_segments"]
    
    def _is_dream_time(self) -> bool:
        """Check if current time is in a dream time period"""
        if not self.dream_mode_enabled:
            return False
        
        now = datetime.datetime.now()
        current_time = now.strftime("%H:%M")
        
        for period in self.dream_times:
            if period["start"] <= current_time <= period["end"]:
                return True
        
        return False
    
    def process_text(self, 
                    text: str, 
                    mode: Optional[str] = None,
                    max_segments: Optional[int] = None,
                    tags: Optional[List[str]] = None) -> List[TextFragment]:
        """Process text using the specified mode"""
        # Select mode if not specified
        if mode is None:
            if self._is_dream_time():
                mode = "dream"
            else:
                mode = random.choice(self.modes)
        
        # Determine max segments
        segments_limit = max_segments or self._get_max_segments()
        
        # Use the appropriate processor
        if mode in self.processors:
            result = self.processors[mode](text, segments_limit, tags)
        else:
            # Default to cut processor if mode not found
            result = self._cut_processor(text, segments_limit, tags)
        
        # Add to history
        self.history.append({
            "timestamp": time.time(),
            "mode": mode,
            "input_length": len(text),
            "output_fragments": len(result),
            "max_segments": segments_limit,
            "dream_time": self._is_dream_time()
        })
        
        return result
    
    def _cut_processor(self, 
                      text: str, 
                      max_segments: int, 
                      tags: Optional[List[str]] = None) -> List[TextFragment]:
        """Cut text into segments at punctuation marks or spaces"""
        # Find natural break points (sentences, phrases, paragraphs)
        sentences = re.split(r'(?<=[.!?])\s+', text)
        
        # If we have fewer sentences than max_segments, break at commas too
        if len(sentences) < max_segments:
            fragments = []
            for sentence in sentences:
                fragments.extend(re.split(r'(?<=,)\s+', sentence))
        else:
            fragments = sentences
        
        # If still fewer than max_segments, break at spaces
        if len(fragments) < max_segments:
            new_fragments = []
            for fragment in fragments:
                words = fragment.split()
                if len(words) > 1:
                    # Split fragment in half
                    mid = len(words) // 2
                    new_fragments.append(" ".join(words[:mid]))
                    new_fragments.append(" ".join(words[mid:]))
                else:
                    new_fragments.append(fragment)
            fragments = new_fragments
        
        # Limit to max_segments
        if len(fragments) > max_segments:
            fragments = fragments[:max_segments]
        
        # Create TextFragment objects
        result = []
        for i, fragment in enumerate(fragments):
            if not fragment.strip():
                continue
            
            result.append(TextFragment(
                content=fragment.strip(),
                index=i,
                type="cut",
                tags=tags or [],
                timestamp=time.time()
            ))
        
        # Store fragments
        self.fragments.extend(result)
        
        return result
    
    def _splice_processor(self, 
                         text: str, 
                         max_segments: int, 
                         tags: Optional[List[str]] = None) -> List[TextFragment]:
        """Splice text by interleaving segments"""
        # First cut the text into fragments
        fragments = self._cut_processor(text, max_segments * 2, tags)
        
        # Splice by interleaving odd and even fragments
        odd_fragments = [f for i, f in enumerate(fragments) if i % 2 == 1]
        even_fragments = [f for i, f in enumerate(fragments) if i % 2 == 0]
        
        # Interleave fragments
        spliced = []
        for i in range(max(len(odd_fragments), len(even_fragments))):
            if i < len(even_fragments):
                frag = even_fragments[i]
                frag.type = "splice_even"
                spliced.append(frag)
            
            if i < len(odd_fragments):
                frag = odd_fragments[i]
                frag.type = "splice_odd"
                spliced.append(frag)
        
        # Limit to max_segments
        spliced = spliced[:max_segments]
        
        # Update indices
        for i, fragment in enumerate(spliced):
            fragment.index = i
            fragment.add_tag("spliced")
        
        return spliced
    
    def _unwrap_processor(self, 
                         text: str, 
                         max_segments: int, 
                         tags: Optional[List[str]] = None) -> List[TextFragment]:
        """Unwrap text by breaking at line boundaries and redistributing"""
        # Break at newlines first
        lines = text.split('\n')
        
        # Collect non-empty lines
        non_empty = [line.strip() for line in lines if line.strip()]
        
        # Calculate target segment size
        if len(non_empty) == 0:
            return []
        
        total_chars = sum(len(line) for line in non_empty)
        target_size = max(total_chars // max_segments, 1)
        
        # Combine short lines and split long ones
        result = []
        current_segment = ""
        
        for line in non_empty:
            if len(current_segment) + len(line) <= target_size:
                # Add to current segment
                if current_segment:
                    current_segment += " "
                current_segment += line
            else:
                # Current segment is full
                if current_segment:
                    result.append(current_segment)
                
                # Start new segment with this line
                if len(line) <= target_size:
                    current_segment = line
                else:
                    # Split long line into multiple segments
                    words = line.split()
                    current_segment = ""
                    for word in words:
                        if len(current_segment) + len(word) + 1 <= target_size:
                            if current_segment:
                                current_segment += " "
                            current_segment += word
                        else:
                            result.append(current_segment)
                            current_segment = word
                            
                            # Check if we've reached max_segments
                            if len(result) >= max_segments - 1:
                                break
                    
                    if current_segment and len(result) < max_segments:
                        result.append(current_segment)
                        current_segment = ""
            
            # Check if we've reached max_segments
            if len(result) >= max_segments:
                break
        
        # Add any remaining content
        if current_segment and len(result) < max_segments:
            result.append(current_segment)
        
        # Create TextFragment objects
        fragments = []
        for i, content in enumerate(result):
            fragments.append(TextFragment(
                content=content,
                index=i,
                type="unwrap",
                tags=(tags or []) + ["unwrapped"],
                timestamp=time.time()
            ))
        
        # Store fragments
        self.fragments.extend(fragments)
        
        return fragments
    
    def _dream_processor(self, 
                        text: str, 
                        max_segments: int, 
                        tags: Optional[List[str]] = None) -> List[TextFragment]:
        """Process text in dream mode - more creative transformations"""
        # First cut the text into fragments
        fragments = self._cut_processor(text, max_segments, tags)
        
        # Perform dream transformations
        result = []
        for fragment in fragments:
            # Apply random transformations
            transformed = self._apply_dream_transformation(fragment.content)
            
            # Create new fragment
            dream_fragment = TextFragment(
                content=transformed,
                index=fragment.index,
                type="dream",
                tags=(fragment.tags or []) + ["dream"],
                parent_id=fragment.id,
                timestamp=time.time()
            )
            
            result.append(dream_fragment)
        
        # Store fragments
        self.fragments.extend(result)
        
        return result
    
    def _apply_dream_transformation(self, text: str) -> str:
        """Apply creative transformations to text in dream mode"""
        # Choose a random transformation
        transform_type = random.choice([
            "reverse_words",
            "echo_phrases",
            "extend_vowels",
            "shuffled",
            "mirrored"
        ])
        
        if transform_type == "reverse_words":
            # Reverse order of words
            words = text.split()
            return " ".join(reversed(words))
        
        elif transform_type == "echo_phrases":
            # Repeat important phrases
            words = text.split()
            if len(words) < 3:
                return text
            
            start_idx = random.randint(0, max(0, len(words) - 3))
            phrase_len = random.randint(1, min(3, len(words) - start_idx))
            phrase = " ".join(words[start_idx:start_idx+phrase_len])
            
            echo_count = random.randint(1, 3)
            echo_text = " " + " ".join([phrase] * echo_count)
            
            insertion_point = random.randint(0, len(text))
            return text[:insertion_point] + echo_text + text[insertion_point:]
        
        elif transform_type == "extend_vowels":
            # Extend vowels for emphasis
            vowels = "aeiouAEIOU"
            result = ""
            for char in text:
                if char in vowels and random.random() < 0.3:
                    # Extend this vowel
                    repeat_count = random.randint(1, 3)
                    result += char * repeat_count
                else:
                    result += char
            return result
        
        elif transform_type == "shuffled":
            # Shuffle words while preserving some structure
            words = text.split()
            if len(words) < 4:
                return text
            
            # Keep first and last word, shuffle the middle
            middle = words[1:-1]
            random.shuffle(middle)
            return words[0] + " " + " ".join(middle) + " " + words[-1]
        
        elif transform_type == "mirrored":
            # Create a mirrored version of text
            return text + " | " + text[::-1]
        
        return text
    
    def _fold_processor(self, 
                       text: str, 
                       max_segments: int, 
                       tags: Optional[List[str]] = None) -> List[TextFragment]:
        """Fold text by combining start and end segments"""
        # First cut the text into fragments
        fragments = self._cut_processor(text, max_segments * 2, tags)
        
        if len(fragments) < 2:
            return fragments
        
        # Fold by combining start and end
        folded = []
        mid_point = len(fragments) // 2
        
        for i in range(mid_point):
            # Get matching fragments from start and end
            start_frag = fragments[i]
            end_frag = fragments[len(fragments) - 1 - i] if i < len(fragments) - 1 - i else None
            
            # Combine fragments
            if end_frag:
                combined = f"{start_frag.content} ⟫ {end_frag.content}"
                
                folded.append(TextFragment(
                    content=combined,
                    index=i,
                    type="fold",
                    tags=(tags or []) + ["folded"],
                    timestamp=time.time()
                ))
        
        # Add middle fragment if odd number
        if len(fragments) % 2 == 1:
            middle = fragments[mid_point]
            middle.type = "fold_center"
            middle.add_tag("folded_center")
            folded.append(middle)
        
        # Limit to max_segments
        folded = folded[:max_segments]
        
        # Update indices
        for i, fragment in enumerate(folded):
            fragment.index = i
        
        # Store fragments
        self.fragments.extend(folded)
        
        return folded
    
    def save_fragments(self, filename: Optional[str] = None) -> str:
        """Save fragments to a file"""
        if not filename:
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"fragments_{timestamp}.json"
        
        filepath = os.path.join(self.output_dir, filename)
        
        # Convert fragments to dictionaries
        data = {
            "fragments": [fragment.to_dict() for fragment in self.fragments],
            "history": self.history,
            "timestamp": time.time(),
            "fragment_count": len(self.fragments),
            "dream_time": self._is_dream_time()
        }
        
        # Save to file
        with open(filepath, 'w') as file:
            json.dump(data, file, indent=2)
        
        return filepath
    
    def load_fragments(self, filepath: str) -> bool:
        """Load fragments from a file"""
        if not os.path.exists(filepath):
            return False
        
        try:
            with open(filepath, 'r') as file:
                data = json.load(file)
            
            # Clear existing fragments
            self.fragments = []
            
            # Load fragments
            for fragment_data in data.get("fragments", []):
                fragment = TextFragment.from_dict(fragment_data)
                self.fragments.append(fragment)
            
            # Load history
            self.history = data.get("history", [])
            
            return True
        
        except Exception as e:
            print(f"Error loading fragments: {e}")
            return False
    
    def get_fragments_by_tag(self, tag: str) -> List[TextFragment]:
        """Get fragments that have a specific tag"""
        return [fragment for fragment in self.fragments if tag in fragment.tags]
    
    def get_fragments_by_type(self, type_name: str) -> List[TextFragment]:
        """Get fragments of a specific type"""
        return [fragment for fragment in self.fragments if fragment.type == type_name]
    
    def merge_fragments(self, 
                       fragment_indices: List[int], 
                       separator: str = " ") -> TextFragment:
        """Merge multiple fragments into a single fragment"""
        fragments = [self.fragments[i] for i in fragment_indices if 0 <= i < len(self.fragments)]
        
        if not fragments:
            return None
        
        # Combine content
        combined_content = separator.join(fragment.content for fragment in fragments)
        
        # Collect tags
        all_tags = []
        for fragment in fragments:
            all_tags.extend(fragment.tags)
        unique_tags = list(set(all_tags))
        
        # Create merged fragment
        merged = TextFragment(
            content=combined_content,
            index=max(fragment.index for fragment in fragments) + 1,
            type="merged",
            tags=unique_tags + ["merged"],
            timestamp=time.time()
        )
        
        # Add parent IDs in metadata
        merged.metadata["parent_ids"] = [fragment.id for fragment in fragments]
        
        # Add to fragments list
        self.fragments.append(merged)
        
        return merged
    
    def render_fragments_as_text(self, 
                               fragments: Optional[List[TextFragment]] = None,
                               separator: str = "\n",
                               include_metadata: bool = False) -> str:
        """Render fragments as a single text string"""
        if fragments is None:
            fragments = self.fragments
        
        lines = []
        
        for fragment in fragments:
            if include_metadata:
                metadata = f"[{fragment.type} {','.join(fragment.tags)}]"
                lines.append(f"{metadata} {fragment.content}")
            else:
                lines.append(fragment.content)
        
        return separator.join(lines)

class TimedTextProcessor:
    """Process text with time-based settings"""
    
    def __init__(self,
                splicer: Optional[TextSplicer] = None,
                time_settings: Optional[Dict[str, Dict[str, Any]]] = None):
        """Initialize the timed text processor"""
        self.splicer = splicer or TextSplicer()
        self.time_settings = time_settings or {
            "7": {"mode": "cut", "max_segments": 7},
            "8": {"mode": "splice", "max_segments": 8},
            "9": {"mode": "unwrap", "max_segments": 9},
            "10": {"mode": "fold", "max_segments": 10}
        }
        self.last_process_time = None
    
    def process_text(self, text: str) -> List[TextFragment]:
        """Process text based on current time"""
        now = datetime.datetime.now()
        hour = str(now.hour)
        
        # Use the closest hour setting
        found_hour = None
        for time_hour in self.time_settings.keys():
            if time_hour == hour:
                found_hour = time_hour
                break
            
            if found_hour is None or abs(int(time_hour) - now.hour) < abs(int(found_hour) - now.hour):
                found_hour = time_hour
        
        # Get settings for this hour
        settings = self.time_settings[found_hour]
        mode = settings.get("mode")
        max_segments = settings.get("max_segments")
        
        # Add time-related tags
        tags = [f"hour_{hour}", self._get_time_period()]
        
        # Record processing time
        self.last_process_time = now
        
        # Process the text
        return self.splicer.process_text(text, mode, max_segments, tags)
    
    def _get_time_period(self) -> str:
        """Get the current time period string"""
        now = datetime.datetime.now()
        hour = now.hour
        
        if 7 <= hour < 12:
            return "morning"
        elif 12 <= hour < 17:
            return "afternoon"
        elif 17 <= hour < 22:
            return "evening"
        else:
            return "night"
    
    def save_settings(self, filepath: str) -> bool:
        """Save time settings to a file"""
        try:
            directory = os.path.dirname(filepath)
            if directory:
                os.makedirs(directory, exist_ok=True)
            
            data = {
                "time_settings": self.time_settings,
                "last_process_time": self.last_process_time.isoformat() if self.last_process_time else None
            }
            
            with open(filepath, 'w') as file:
                json.dump(data, file, indent=2)
            
            return True
        
        except Exception as e:
            print(f"Error saving settings: {e}")
            return False
    
    def load_settings(self, filepath: str) -> bool:
        """Load time settings from a file"""
        if not os.path.exists(filepath):
            return False
        
        try:
            with open(filepath, 'r') as file:
                data = json.load(file)
            
            self.time_settings = data.get("time_settings", self.time_settings)
            
            last_time = data.get("last_process_time")
            if last_time:
                self.last_process_time = datetime.datetime.fromisoformat(last_time)
            
            return True
        
        except Exception as e:
            print(f"Error loading settings: {e}")
            return False
    
    def add_time_setting(self, hour: str, mode: str, max_segments: int) -> None:
        """Add or update a time setting"""
        self.time_settings[hour] = {
            "mode": mode,
            "max_segments": max_segments
        }
    
    def remove_time_setting(self, hour: str) -> bool:
        """Remove a time setting"""
        if hour in self.time_settings:
            del self.time_settings[hour]
            return True
        return False

def main():
    """Command line interface for the text splicer"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Text Splicer and Unwrapper")
    parser.add_argument("--text", help="Text to process")
    parser.add_argument("--file", help="Input file path")
    parser.add_argument("--mode", choices=DEFAULT_MODES, help="Processing mode")
    parser.add_argument("--max", type=int, help="Maximum number of segments")
    parser.add_argument("--output", help="Output file path")
    parser.add_argument("--timed", action="store_true", help="Use time-based processing")
    parser.add_argument("--dream", action="store_true", help="Force dream mode")
    
    args = parser.parse_args()
    
    # Get the input text
    text = args.text
    if args.file:
        try:
            with open(args.file, 'r', encoding='utf-8') as file:
                text = file.read()
        except Exception as e:
            print(f"Error reading file: {e}")
            return
    
    if not text:
        print("No text provided. Use --text or --file.")
        return
    
    # Set up the processor
    if args.timed:
        processor = TimedTextProcessor()
        fragments = processor.process_text(text)
    else:
        splicer = TextSplicer(max_segments=args.max)
        
        # Use dream mode if requested or if it's dream time
        mode = args.mode
        if args.dream:
            mode = "dream"
        
        fragments = splicer.process_text(text, mode=mode)
    
    # Output the results
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as file:
            if args.output.endswith('.json'):
                # Save as JSON
                data = {
                    "fragments": [fragment.to_dict() for fragment in fragments],
                    "timestamp": time.time(),
                    "fragment_count": len(fragments)
                }
                json.dump(data, file, indent=2)
            else:
                # Save as text
                for i, fragment in enumerate(fragments):
                    file.write(f"{i+1}. {fragment.content}\n")
        
        print(f"Output saved to {args.output}")
    else:
        # Print to console
        print(f"Processed into {len(fragments)} fragments:")
        for i, fragment in enumerate(fragments):
            print(f"{i+1}. [{fragment.type}] {fragment.content}")

if __name__ == "__main__":
    main()