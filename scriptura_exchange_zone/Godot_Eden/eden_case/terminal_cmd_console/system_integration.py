#!/usr/bin/env python3
# System Integration - Connects wish_console with all modules
# Creates a unified system with OCR, connection manager, and data visualization

import os
import sys
import time
import json
import random
import threading
import curses
import subprocess
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple, Set

# Import local modules (with error handling)
try:
    from connection_manager import ConnectionManager, Connection, ConnectionType, ConnectionState
except ImportError:
    print("Warning: connection_manager.py not found or contains errors")
    ConnectionManager = None

try:
    from data_sea_visualizer import SeaOfData, DataPoint
except ImportError:
    print("Warning: data_sea_visualizer.py not found or contains errors")
    SeaOfData = None

# Constants
CONFIG = {
    "debug_mode": False,
    "auto_save_interval": 60,  # seconds
    "ocr_enabled": True,
    "ocr_check_interval": 5,  # seconds
    "system_style": "digital",  # Options: minimal, digital, maximal, glitch
    "color_scheme": "blue",    # Options: blue, green, rainbow, monochrome
    "visualizer_enabled": True,
    "godot_integration_enabled": False,
    "godot_port": 9876,
    "max_reason_depth": 5,
    "default_dimension": 3,     # Default dimension for new memories (SPATIAL)
    "auto_connect_apis": True,
    "max_glitch_level": 7,      # 1-9 scale
    "human_interaction_threshold": 0.7,  # 0.0-1.0
    "power_save_mode": False
}

class OCRProcessor:
    """Processes OCR data and extracts meaning"""
    
    def __init__(self):
        self.active = False
        self.thread = None
        self.last_checked = 0
        self.recognized_text = []
        self.analysis_results = {}
        self.confidence_threshold = 0.6  # Minimum confidence to accept OCR result
        self.ocr_lib_available = self._check_ocr_lib()
        self.last_image_path = None
        self.image_queue = []
        self.self_check_enabled = True
        self.human_interaction_detected = False
        self.interaction_confidence = 0.0
        
    def _check_ocr_lib(self) -> bool:
        """Check if OCR library is available"""
        try:
            # First try importing Python OCR libraries
            import cv2
            import pytesseract
            return True
        except ImportError:
            try:
                # Fall back to simple OCR if available
                if os.path.exists("simple_ocr.py"):
                    return True
            except:
                pass
        return False
        
    def start(self) -> bool:
        """Start OCR processing thread"""
        if not self.ocr_lib_available:
            print("OCR libraries not available, cannot start OCR processing")
            return False
            
        if self.active:
            return True  # Already running
            
        def ocr_thread():
            while self.active:
                current_time = time.time()
                if current_time - self.last_checked >= CONFIG["ocr_check_interval"]:
                    self._process_ocr()
                    self.last_checked = current_time
                    
                    # Self-check if enabled
                    if self.self_check_enabled and random.random() < 0.1:  # 10% chance
                        self._perform_self_check()
                        
                time.sleep(0.1)  # Sleep to prevent high CPU usage
        
        self.active = True
        self.thread = threading.Thread(target=ocr_thread)
        self.thread.daemon = True
        self.thread.start()
        return True
        
    def stop(self) -> None:
        """Stop OCR processing"""
        self.active = False
        if self.thread:
            self.thread.join(timeout=1.0)
            
    def queue_image(self, image_path: str) -> None:
        """Add an image to the processing queue"""
        if os.path.exists(image_path):
            self.image_queue.append(image_path)
        
    def _process_ocr(self) -> None:
        """Process any queued images with OCR"""
        if not self.image_queue:
            return
            
        image_path = self.image_queue.pop(0)
        self.last_image_path = image_path
        
        try:
            # Try to use external simple_ocr.py script if available
            if os.path.exists("simple_ocr.py"):
                result = subprocess.run(
                    [sys.executable, "simple_ocr.py", image_path],
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                
                if result.returncode == 0:
                    text = result.stdout.strip()
                    if text:
                        self.recognized_text.append({
                            "text": text,
                            "source": image_path,
                            "timestamp": datetime.now().isoformat(),
                            "confidence": 0.7  # Assumed confidence
                        })
                        self._analyze_text(text)
            else:
                # Try to use Python libraries
                import cv2
                import pytesseract
                
                image = cv2.imread(image_path)
                if image is not None:
                    text = pytesseract.image_to_string(image)
                    if text:
                        self.recognized_text.append({
                            "text": text,
                            "source": image_path,
                            "timestamp": datetime.now().isoformat(),
                            "confidence": 0.8  # Assumed confidence
                        })
                        self._analyze_text(text)
        except Exception as e:
            if CONFIG["debug_mode"]:
                print(f"OCR error: {e}")
                
    def _analyze_text(self, text: str) -> Dict[str, Any]:
        """Analyze recognized text for meaning and structure"""
        words = text.split()
        
        # Simple analysis
        analysis = {
            "word_count": len(words),
            "character_count": len(text),
            "contains_numbers": any(char.isdigit() for char in text),
            "keywords": [],
            "sentiment": "neutral",
            "classification": "unknown"
        }
        
        # Extract keywords (simplified)
        common_words = {"the", "and", "a", "an", "in", "on", "at", "to", "for", "with", "by"}
        keywords = [word.lower() for word in words 
                   if word.lower() not in common_words and len(word) > 3]
        analysis["keywords"] = keywords[:10]  # Top 10 keywords
        
        # Very basic sentiment analysis
        positive_words = {"good", "great", "excellent", "amazing", "wonderful", "positive", "happy"}
        negative_words = {"bad", "terrible", "awful", "poor", "negative", "sad", "unhappy"}
        
        pos_count = sum(1 for word in words if word.lower() in positive_words)
        neg_count = sum(1 for word in words if word.lower() in negative_words)
        
        if pos_count > neg_count:
            analysis["sentiment"] = "positive"
        elif neg_count > pos_count:
            analysis["sentiment"] = "negative"
            
        # Check for human interaction markers
        human_markers = {"I", "me", "my", "mine", "we", "us", "our", "ours", "you", "your", "yours"}
        human_marker_count = sum(1 for word in words if word.lower() in human_markers)
        
        if human_marker_count > 0:
            human_confidence = min(1.0, human_marker_count / len(words) * 3)  # Scale up but max at 1.0
            analysis["human_interaction"] = human_confidence
            
            if human_confidence > CONFIG["human_interaction_threshold"]:
                self.human_interaction_detected = True
                self.interaction_confidence = human_confidence
        
        # Store analysis results
        self.analysis_results[datetime.now().isoformat()] = analysis
        return analysis
        
    def _perform_self_check(self) -> float:
        """Perform a self-check of the OCR system quality"""
        if not self.recognized_text:
            return 0.0
            
        # Check recent OCR results for quality indicators
        recent_results = self.recognized_text[-5:]  # Last 5 results
        
        # Calculate average confidence
        avg_confidence = sum(result.get("confidence", 0) for result in recent_results) / len(recent_results)
        
        # Check for empty or very short results
        empty_ratio = sum(1 for result in recent_results if len(result.get("text", "")) < 10) / len(recent_results)
        
        # Overall quality score
        quality_score = avg_confidence * (1 - empty_ratio)
        
        if CONFIG["debug_mode"]:
            print(f"OCR self-check: Quality score = {quality_score:.2f}")
            
        return quality_score
        
    def get_recent_text(self, count: int = 1) -> List[Dict[str, Any]]:
        """Get the most recent recognized text results"""
        return self.recognized_text[-count:] if self.recognized_text else []
        
    def get_human_interaction_status(self) -> Tuple[bool, float]:
        """Get the current human interaction status and confidence"""
        return (self.human_interaction_detected, self.interaction_confidence)
        
    def reset_human_interaction(self) -> None:
        """Reset the human interaction detection"""
        self.human_interaction_detected = False
        self.interaction_confidence = 0.0

class IntegratedSystem:
    """Integrates all components into a unified system"""
    
    def __init__(self, load_config: bool = True):
        self.wish_console = None
        self.connection_manager = None if ConnectionManager is None else ConnectionManager()
        self.data_visualizer = None if SeaOfData is None else SeaOfData()
        self.ocr_processor = OCRProcessor()
        self.running = False
        self.auto_save_timer = 0
        self.curses_screen = None
        self.display_mode = "console"  # console, visualizer, split
        self.visualizer_thread = None
        self.apis_integrated = False
        self.godot_handler = None
        self.last_update = time.time()
        self.update_count = 0
        self.status_message = ""
        self.command_queue = []
        self.power_save_mode = CONFIG["power_save_mode"]
        self.integration_complete = False
        
        # Load configuration if requested
        if load_config:
            self._load_config()
            
    def _load_config(self) -> None:
        """Load system configuration"""
        try:
            if os.path.exists("system_config.json"):
                with open("system_config.json", "r") as f:
                    loaded_config = json.load(f)
                    CONFIG.update(loaded_config)
        except Exception as e:
            print(f"Error loading system config: {e}")
    
    def _save_config(self) -> None:
        """Save system configuration"""
        try:
            with open("system_config.json", "w") as f:
                json.dump(CONFIG, f, indent=2)
        except Exception as e:
            print(f"Error saving system config: {e}")
            
    def init_components(self) -> None:
        """Initialize all system components"""
        # Import and initialize wish_console
        try:
            sys.path.append(os.getcwd())
            from wish_console import WishConsole
            self.wish_console = WishConsole()
            print("Wish Console initialized")
        except ImportError as e:
            print(f"Error importing wish_console: {e}")
            return False
            
        # Initialize connection manager if available
        if self.connection_manager:
            if hasattr(self.connection_manager, "integrate_with_wish_console"):
                self.connection_manager.integrate_with_wish_console(self.wish_console)
            print("Connection Manager initialized and integrated")
            
        # Initialize data visualizer if available
        if self.data_visualizer and CONFIG["visualizer_enabled"]:
            if hasattr(self.data_visualizer, "integrate_with_wish_console"):
                self.data_visualizer.integrate_with_wish_console(
                    self.wish_console, self.connection_manager
                )
            print("Data Visualizer initialized and integrated")
            
        # Initialize OCR processor if enabled
        if CONFIG["ocr_enabled"]:
            if self.ocr_processor.ocr_lib_available:
                print("OCR Processor initialized")
            else:
                print("OCR libraries not available, OCR processing disabled")
                CONFIG["ocr_enabled"] = False
                
        # Mark integration as complete
        self.integration_complete = True
        return True
    
    def start(self) -> bool:
        """Start the integrated system"""
        if self.running:
            return True  # Already running
            
        # Initialize components if not already done
        if not self.integration_complete:
            success = self.init_components()
            if not success:
                return False
                
        # Start wish console
        if hasattr(self.wish_console, "start"):
            self.wish_console.start()
            
        # Start connection manager
        if self.connection_manager:
            self.connection_manager.start_monitor()
            
        # Start OCR processor if enabled
        if CONFIG["ocr_enabled"]:
            self.ocr_processor.start()
            
        # Start data visualizer in separate thread if enabled
        if self.data_visualizer and CONFIG["visualizer_enabled"] and self.display_mode == "visualizer":
            self._start_visualizer_thread()
            
        # Start auto-save timer
        self.auto_save_timer = time.time()
        
        # Mark system as running
        self.running = True
        self.status_message = "System started successfully"
        return True
        
    def stop(self) -> None:
        """Stop the integrated system"""
        self.running = False
        
        # Stop wish console
        if self.wish_console and hasattr(self.wish_console, "stop"):
            self.wish_console.stop()
            
        # Stop connection manager
        if self.connection_manager:
            self.connection_manager.stop_monitor()
            
        # Stop OCR processor
        if CONFIG["ocr_enabled"]:
            self.ocr_processor.stop()
            
        # Stop visualizer thread
        if self.visualizer_thread:
            # Signal to stop and wait for thread to end
            if hasattr(self, "visualizer_running"):
                self.visualizer_running = False
            self.visualizer_thread.join(timeout=1.0)
            
        # Save config and state before exiting
        self._save_config()
        self._save_state()
        
    def _start_visualizer_thread(self) -> None:
        """Start the data visualizer in a separate thread"""
        if not self.data_visualizer:
            return
            
        def visualizer_thread():
            # Initialize curses for the visualizer
            self.visualizer_running = True
            
            def curses_main(stdscr):
                # Setup curses
                curses.curs_set(0)  # Hide cursor
                stdscr.timeout(50)  # Non-blocking input
                
                # Setup colors
                self.data_visualizer.setup_curses_colors()
                
                # Get terminal dimensions
                height, width = stdscr.getmaxyx()
                self.data_visualizer.resize(width, height)
                
                # Main visualizer loop
                last_time = time.time()
                while self.visualizer_running:
                    # Calculate time delta
                    current_time = time.time()
                    dt = current_time - last_time
                    last_time = current_time
                    
                    # Handle input
                    try:
                        key = stdscr.getch()
                        if key == ord('q'):
                            self.visualizer_running = False
                        elif key == ord('c'):
                            # Switch to console mode
                            self.display_mode = "console"
                            self.visualizer_running = False
                    except:
                        pass
                    
                    # Update data from wish console periodically
                    if current_time - self.last_update >= 1.0:  # Once per second
                        self.data_visualizer.integrate_with_wish_console(
                            self.wish_console, self.connection_manager
                        )
                        self.last_update = current_time
                    
                    # Update and render visualizer
                    self.data_visualizer.update(dt)
                    self.data_visualizer.render(stdscr)
                    
                    # Sleep to control frame rate
                    time.sleep(0.05)
            
            # Start curses visualizer
            try:
                curses.wrapper(curses_main)
            except Exception as e:
                print(f"Visualizer error: {e}")
            finally:
                self.visualizer_running = False
                
        self.visualizer_thread = threading.Thread(target=visualizer_thread)
        self.visualizer_thread.daemon = True
        self.visualizer_thread.start()
        
    def _process_queued_commands(self) -> None:
        """Process any queued commands"""
        while self.command_queue:
            cmd = self.command_queue.pop(0)
            self._process_command(cmd)
            
    def _process_command(self, command: str) -> Optional[str]:
        """Process a system command"""
        if not command:
            return None
            
        # Split command and arguments
        parts = command.split(maxsplit=1)
        cmd = parts[0].lower()
        args = parts[1] if len(parts) > 1 else ""
        
        result = None
        
        # System commands
        if cmd == "switch":
            # Switch display mode
            if args in ["console", "visualizer", "split"]:
                old_mode = self.display_mode
                self.display_mode = args
                
                if old_mode == "visualizer" and args != "visualizer":
                    # Stop visualizer thread
                    self.visualizer_running = False
                    if self.visualizer_thread:
                        self.visualizer_thread.join(timeout=1.0)
                        self.visualizer_thread = None
                        
                if args == "visualizer" and old_mode != "visualizer":
                    # Start visualizer thread
                    self._start_visualizer_thread()
                    
                result = f"Display mode switched to {args}"
                
        elif cmd == "power":
            # Toggle power save mode
            if args == "save":
                self.power_save_mode = True
                CONFIG["power_save_mode"] = True
                result = "Power save mode enabled"
            elif args == "normal":
                self.power_save_mode = False
                CONFIG["power_save_mode"] = False
                result = "Power save mode disabled"
                
        elif cmd == "debug":
            # Toggle debug mode
            if args == "on":
                CONFIG["debug_mode"] = True
                result = "Debug mode enabled"
            elif args == "off":
                CONFIG["debug_mode"] = False
                result = "Debug mode disabled"
                
        elif cmd == "save":
            # Save system state
            self._save_state()
            result = "System state saved"
            
        elif cmd == "status":
            # Display system status
            result = self._get_status()
            
        elif cmd == "ocr":
            # OCR commands
            if args.startswith("scan "):
                image_path = args[5:].strip()
                self.ocr_processor.queue_image(image_path)
                result = f"Image queued for OCR: {image_path}"
            elif args == "status":
                if self.ocr_processor.human_interaction_detected:
                    result = f"Human interaction detected (confidence: {self.ocr_processor.interaction_confidence:.2f})"
                else:
                    result = "No human interaction detected"
            elif args == "reset":
                self.ocr_processor.reset_human_interaction()
                result = "Human interaction status reset"
                
        # Pass to wish console if not handled
        elif self.wish_console and hasattr(self.wish_console, "process_command"):
            result = self.wish_console.process_command(command)
            
        return result
        
    def process_command(self, command: str) -> Optional[str]:
        """Process a command or queue it for later processing"""
        if not self.running:
            return "System not running, command ignored"
            
        self.command_queue.append(command)
        return None  # Queued for processing
        
    def _get_status(self) -> str:
        """Get the current system status"""
        status = []
        status.append("INTEGRATED SYSTEM STATUS")
        status.append("======================")
        
        # System info
        status.append(f"Display Mode: {self.display_mode}")
        status.append(f"Power Save: {'Enabled' if self.power_save_mode else 'Disabled'}")
        status.append(f"Debug Mode: {'Enabled' if CONFIG['debug_mode'] else 'Disabled'}")
        status.append(f"Update Count: {self.update_count}")
        
        # Wish Console status
        if self.wish_console:
            status.append("\nWISH CONSOLE")
            status.append(f"- Memories: {len(getattr(self.wish_console, 'memories', []))}")
            status.append(f"- Wishes: {len(getattr(self.wish_console, 'wishes', []))}")
            
            # API status
            if hasattr(self.wish_console, 'apis'):
                status.append("\nAPI STATUS")
                for name, api in self.wish_console.apis.items():
                    status.append(f"- {name}: {'ONLINE' if api.is_online else 'OFFLINE'}")
                    
        # Connection Manager status
        if self.connection_manager:
            total = len(self.connection_manager.connections)
            active = sum(1 for c in self.connection_manager.connections.values() 
                         if c.state == ConnectionState.ACTIVE)
            status.append("\nCONNECTIONS")
            status.append(f"- Total: {total}")
            status.append(f"- Active: {active}")
            status.append(f"- Inactive: {total - active}")
            
        # OCR status
        if CONFIG["ocr_enabled"] and self.ocr_processor:
            status.append("\nOCR PROCESSOR")
            status.append(f"- Active: {'Yes' if self.ocr_processor.active else 'No'}")
            status.append(f"- Results: {len(self.ocr_processor.recognized_text)}")
            status.append(f"- Human Interaction: {'Detected' if self.ocr_processor.human_interaction_detected else 'None'}")
            if self.ocr_processor.human_interaction_detected:
                status.append(f"  Confidence: {self.ocr_processor.interaction_confidence:.2f}")
                
        return "\n".join(status)
    
    def _save_state(self) -> bool:
        """Save the current system state"""
        try:
            state = {
                "timestamp": datetime.now().isoformat(),
                "update_count": self.update_count,
                "display_mode": self.display_mode,
                "power_save_mode": self.power_save_mode,
                "status_message": self.status_message
            }
            
            # Save OCR state
            if CONFIG["ocr_enabled"] and self.ocr_processor:
                state["ocr"] = {
                    "active": self.ocr_processor.active,
                    "human_interaction": self.ocr_processor.human_interaction_detected,
                    "interaction_confidence": self.ocr_processor.interaction_confidence,
                    "result_count": len(self.ocr_processor.recognized_text)
                }
                
            # Save connections state
            if self.connection_manager:
                self.connection_manager.save_to_file("connections.json")
                
            # Write state file
            with open("system_state.json", "w") as f:
                json.dump(state, f, indent=2)
                
            return True
        except Exception as e:
            print(f"Error saving system state: {e}")
            return False
            
    def update(self) -> None:
        """Update the integrated system"""
        if not self.running:
            return
            
        current_time = time.time()
        dt = current_time - self.last_update
        self.last_update = current_time
        
        # Process queued commands
        self._process_queued_commands()
        
        # Auto-save if interval elapsed
        if current_time - self.auto_save_timer >= CONFIG["auto_save_interval"]:
            self._save_state()
            self.auto_save_timer = current_time
            
        # Check human interaction from OCR
        if CONFIG["ocr_enabled"] and self.ocr_processor:
            human_detected, confidence = self.ocr_processor.get_human_interaction_status()
            if human_detected:
                # Take action based on human interaction
                if confidence > 0.8:  # High confidence
                    # Add a memory about the human interaction
                    if self.wish_console and hasattr(self.wish_console, "add_memory"):
                        content = f"Human interaction detected with high confidence ({confidence:.2f})"
                        self.wish_console.add_memory(content, tags=["#human", "#interaction"])
                        
                # Reset after processing
                self.ocr_processor.reset_human_interaction()
                
        # Update count
        self.update_count += 1
        
        # Apply power saving if enabled
        if self.power_save_mode:
            # Sleep to reduce update frequency
            time.sleep(0.1)
            
def main() -> None:
    """Main function for the integrated system"""
    # Create integrated system
    system = IntegratedSystem()
    
    # Initialize components
    if not system.init_components():
        print("Failed to initialize components, exiting")
        return
        
    # Start the system
    if not system.start():
        print("Failed to start system, exiting")
        return
        
    print("Integrated system started")
    print("Enter 'quit' or 'exit' to stop")
    
    # Main loop
    try:
        while system.running:
            # Get user input
            try:
                command = input("> ").strip()
                if command.lower() in ["quit", "exit"]:
                    break
                    
                # Process command
                result = system.process_command(command)
                if result:
                    print(result)
            except EOFError:
                break
                
            # Update system
            system.update()
    except KeyboardInterrupt:
        print("\nInterrupted by user")
    finally:
        # Stop the system
        system.stop()
        print("System stopped")

if __name__ == "__main__":
    main()