#!/usr/bin/env python3
# Eye Tracking System - Tracks eye movements and provides focus insights
# Integrates with wish_console and works offline with split mode support

import os
import sys
import time
import json
import random
import threading
import numpy as np
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple, Set, Union

# Check for optional dependencies
try:
    import cv2
    CV2_AVAILABLE = True
except ImportError:
    CV2_AVAILABLE = False

try:
    from PIL import Image
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False

# Constants
CONFIG = {
    "camera_device": 0,                # Default camera device ID
    "detection_interval": 0.1,         # Seconds between detections
    "confidence_threshold": 0.6,       # Minimum confidence for detections
    "calibration_points": 5,           # Number of calibration points
    "focus_decay_rate": 0.2,           # Rate at which focus decays
    "heatmap_resolution": (50, 30),    # Resolution of attention heatmap
    "offline_mode": False,             # Start in offline mode
    "split_mode_enabled": True,        # Enable split mode processing
    "split_threshold": 0.7,            # Threshold for split attention detection
    "reason_collection_enabled": True, # Collect reasons for attention changes
    "debug_mode": False,               # Show debug information
    "save_interval": 60,               # Seconds between saves
    "privacy_mode": True,              # Don't store raw eye images
    "low_resource_mode": False,        # Use less resources if True
    "max_history_items": 1000,         # Maximum eye tracking history items
}

class EyeState:
    """Represents the state of tracked eyes"""
    
    def __init__(self):
        self.left_open = True
        self.right_open = True
        self.left_position = (0.5, 0.5)  # Normalized (x, y) coordinates
        self.right_position = (0.5, 0.5)  # Normalized (x, y) coordinates
        self.gaze_point = (0.5, 0.5)      # Combined gaze point
        self.blink_detected = False
        self.timestamp = time.time()
        self.confidence = 0.0
        self.screen_point = (0, 0)         # Estimated screen coordinates
        self.dilated = False               # Pupil dilation detection
        self.saccade_detected = False      # Quick eye movement
        self.fixation_duration = 0.0       # Time spent focused
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert eye state to dictionary"""
        return {
            "left_open": self.left_open,
            "right_open": self.right_open,
            "left_position": self.left_position,
            "right_position": self.right_position,
            "gaze_point": self.gaze_point,
            "blink_detected": self.blink_detected,
            "timestamp": self.timestamp,
            "confidence": self.confidence,
            "screen_point": self.screen_point,
            "dilated": self.dilated,
            "saccade_detected": self.saccade_detected,
            "fixation_duration": self.fixation_duration
        }
        
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'EyeState':
        """Create eye state from dictionary"""
        state = cls()
        state.left_open = data.get("left_open", True)
        state.right_open = data.get("right_open", True)
        state.left_position = tuple(data.get("left_position", (0.5, 0.5)))
        state.right_position = tuple(data.get("right_position", (0.5, 0.5)))
        state.gaze_point = tuple(data.get("gaze_point", (0.5, 0.5)))
        state.blink_detected = data.get("blink_detected", False)
        state.timestamp = data.get("timestamp", time.time())
        state.confidence = data.get("confidence", 0.0)
        state.screen_point = tuple(data.get("screen_point", (0, 0)))
        state.dilated = data.get("dilated", False)
        state.saccade_detected = data.get("saccade_detected", False)
        state.fixation_duration = data.get("fixation_duration", 0.0)
        return state

class FocusReason:
    """Tracks reasons for focus changes"""
    
    REASON_TYPES = {
        "content_change": "Screen content changed",
        "user_action": "User initiated action",
        "notification": "System notification",
        "movement": "Motion detected",
        "color_change": "Color/contrast change",
        "text_density": "Text density changed",
        "shape_change": "Shape changed",
        "animation": "Animation occurred",
        "sound": "Sound played",
        "unknown": "Unknown reason"
    }
    
    def __init__(self, 
                reason_type: str = "unknown", 
                description: str = "", 
                confidence: float = 0.0):
        self.reason_type = reason_type
        self.description = description or self.REASON_TYPES.get(reason_type, "")
        self.confidence = confidence
        self.timestamp = time.time()
        self.associated_states: List[float] = []  # Timestamps of associated eye states
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert reason to dictionary"""
        return {
            "reason_type": self.reason_type,
            "description": self.description,
            "confidence": self.confidence,
            "timestamp": self.timestamp,
            "associated_states": self.associated_states
        }
        
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'FocusReason':
        """Create reason from dictionary"""
        reason = cls(
            reason_type=data.get("reason_type", "unknown"),
            description=data.get("description", ""),
            confidence=data.get("confidence", 0.0)
        )
        reason.timestamp = data.get("timestamp", time.time())
        reason.associated_states = data.get("associated_states", [])
        return reason

class FocusMap:
    """Maintains a heatmap of attention focus"""
    
    def __init__(self, resolution: Tuple[int, int] = (50, 30)):
        self.resolution = resolution
        self.width, self.height = resolution
        self.focus_map = np.zeros(resolution, dtype=float)
        self.history_map = np.zeros(resolution, dtype=float)
        self.decay_rate = CONFIG["focus_decay_rate"]
        self.focus_threshold = 0.6  # Threshold for detecting focused areas
        self.max_focus = 1.0
        self.total_updates = 0
        
    def update(self, gaze_point: Tuple[float, float], intensity: float = 1.0) -> None:
        """Update focus map with new gaze point"""
        # Normalize and get grid coordinates
        x_norm, y_norm = gaze_point
        x = int(x_norm * (self.width - 1))
        y = int(y_norm * (self.height - 1))
        
        # Boundary check
        x = max(0, min(x, self.width - 1))
        y = max(0, min(y, self.height - 1))
        
        # Apply gaussian kernel around gaze point
        kernel_size = 5
        for dy in range(-kernel_size, kernel_size + 1):
            for dx in range(-kernel_size, kernel_size + 1):
                kx, ky = x + dx, y + dy
                
                # Skip if outside bounds
                if kx < 0 or kx >= self.width or ky < 0 or ky >= self.height:
                    continue
                
                # Gaussian weight based on distance
                distance = (dx**2 + dy**2) ** 0.5
                weight = np.exp(-(distance**2) / (2 * (kernel_size/2)**2))
                
                # Add to focus map with intensity and weight
                self.focus_map[ky, kx] += weight * intensity
                self.focus_map[ky, kx] = min(self.focus_map[ky, kx], self.max_focus)
                
                # Update history map (accumulates over time)
                self.history_map[ky, kx] += weight * intensity * 0.1
        
        self.total_updates += 1
        
    def decay(self) -> None:
        """Apply decay to focus map"""
        self.focus_map *= (1.0 - self.decay_rate)
        
    def get_focus_regions(self) -> List[Tuple[int, int, float]]:
        """Get current focus regions as (x, y, intensity) list"""
        regions = []
        
        # Find local maxima
        for y in range(self.height):
            for x in range(self.width):
                if self.focus_map[y, x] > self.focus_threshold:
                    # Check if it's a local maximum
                    is_max = True
                    for dy in range(-1, 2):
                        for dx in range(-1, 2):
                            ny, nx = y + dy, x + dx
                            if (0 <= ny < self.height and 0 <= nx < self.width and 
                                (ny != y or nx != x) and 
                                self.focus_map[ny, nx] > self.focus_map[y, x]):
                                is_max = False
                                break
                        if not is_max:
                            break
                    
                    if is_max:
                        regions.append((x, y, self.focus_map[y, x]))
                        
        return regions
        
    def get_focus_pattern(self) -> str:
        """Get a text representation of the focus pattern"""
        result = ""
        
        # Simplified focus map for text representation
        simplified = np.zeros((6, 10), dtype=int)
        
        # Downsample the focus map
        for y in range(6):
            for x in range(10):
                y_start = int(y * self.height / 6)
                y_end = int((y + 1) * self.height / 6)
                x_start = int(x * self.width / 10)
                x_end = int((x + 1) * self.width / 10)
                
                # Get average value in region
                region = self.focus_map[y_start:y_end, x_start:x_end]
                avg = np.mean(region)
                
                # Convert to 0-9 scale
                simplified[y, x] = min(9, int(avg * 10))
        
        # Create text representation
        for y in range(6):
            for x in range(10):
                value = simplified[y, x]
                if value == 0:
                    result += "."
                else:
                    result += str(value)
            result += "\n"
            
        return result
        
    def get_split_attention(self) -> Optional[Tuple[Tuple[int, int], Tuple[int, int]]]:
        """Detect split attention between two regions"""
        regions = self.get_focus_regions()
        
        # Need at least two regions
        if len(regions) < 2:
            return None
            
        # Sort by intensity
        regions.sort(key=lambda r: r[2], reverse=True)
        
        # Check top two regions
        r1, r2 = regions[0], regions[1]
        
        # If both regions have high enough focus and are far enough apart
        distance = ((r1[0] - r2[0])**2 + (r1[1] - r2[1])**2) ** 0.5
        if (r1[2] > self.focus_threshold and 
            r2[2] > self.focus_threshold * 0.7 and 
            distance > 10):
            return ((r1[0], r1[1]), (r2[0], r2[1]))
            
        return None
        
    def reset(self) -> None:
        """Reset the focus map"""
        self.focus_map = np.zeros(self.resolution, dtype=float)
        
    def save_to_file(self, filename: str) -> bool:
        """Save focus maps to file"""
        try:
            data = {
                "focus_map": self.focus_map.tolist(),
                "history_map": self.history_map.tolist(),
                "resolution": self.resolution,
                "total_updates": self.total_updates,
                "timestamp": datetime.now().isoformat()
            }
            
            with open(filename, "w") as f:
                json.dump(data, f)
                
            return True
        except Exception as e:
            print(f"Error saving focus map: {e}")
            return False
            
    def load_from_file(self, filename: str) -> bool:
        """Load focus maps from file"""
        try:
            with open(filename, "r") as f:
                data = json.load(f)
                
            self.focus_map = np.array(data["focus_map"])
            self.history_map = np.array(data["history_map"])
            self.resolution = tuple(data["resolution"])
            self.width, self.height = self.resolution
            self.total_updates = data["total_updates"]
            
            return True
        except Exception as e:
            print(f"Error loading focus map: {e}")
            return False

class EyeTracker:
    """Tracks eye movement and integrates with system"""
    
    def __init__(self):
        # System state
        self.active = False
        self.thread = None
        self.tracking_thread = None
        self.camera = None
        self.frame_width = 640
        self.frame_height = 480
        self.screen_width = 1920  # Will be updated during calibration
        self.screen_height = 1080  # Will be updated during calibration
        self.last_frame = None
        self.offline_mode = CONFIG["offline_mode"]
        self.calibrated = False
        self.calibration_points = []
        
        # Eye tracking state
        self.current_state = EyeState()
        self.state_history: List[EyeState] = []
        self.focus_map = FocusMap(CONFIG["heatmap_resolution"])
        self.reasons: List[FocusReason] = []
        self.last_update = time.time()
        self.last_save = time.time()
        self.detection_counter = 0
        self.blink_counter = 0
        self.focus_regions = []
        self.split_attention = None
        self.eye_cascade = None  # Will be loaded if CV2 is available
        self.face_cascade = None  # Will be loaded if CV2 is available
        
        # Initialize CV2 cascades if available
        self._init_cv2_cascades()
        
    def _init_cv2_cascades(self) -> bool:
        """Initialize OpenCV cascades"""
        if not CV2_AVAILABLE:
            return False
            
        try:
            # Load cascades for face and eye detection
            cascades_dir = os.path.join(cv2.data.haarcascades)
            
            face_cascade_path = os.path.join(cascades_dir, 'haarcascade_frontalface_default.xml')
            eye_cascade_path = os.path.join(cascades_dir, 'haarcascade_eye.xml')
            
            if os.path.exists(face_cascade_path) and os.path.exists(eye_cascade_path):
                self.face_cascade = cv2.CascadeClassifier(face_cascade_path)
                self.eye_cascade = cv2.CascadeClassifier(eye_cascade_path)
                return True
            else:
                print("Warning: OpenCV cascade files not found")
                return False
        except Exception as e:
            print(f"Error initializing CV2 cascades: {e}")
            return False
            
    def start(self) -> bool:
        """Start eye tracking"""
        if self.active:
            return True  # Already running
            
        # Set active flag
        self.active = True
        
        if self.offline_mode:
            # Start simulation thread only
            self.thread = threading.Thread(target=self._simulation_thread)
            self.thread.daemon = True
            self.thread.start()
            print("Eye tracker started in offline mode (simulation)")
            return True
            
        # Check if CV2 is available for camera capture
        if not CV2_AVAILABLE:
            print("OpenCV not available, falling back to offline mode")
            self.offline_mode = True
            return self.start()  # Restart in offline mode
            
        # Start camera thread
        try:
            self.tracking_thread = threading.Thread(target=self._tracking_thread)
            self.tracking_thread.daemon = True
            self.tracking_thread.start()
            
            # Also start processing thread
            self.thread = threading.Thread(target=self._processing_thread)
            self.thread.daemon = True
            self.thread.start()
            
            print("Eye tracker started with camera")
            return True
        except Exception as e:
            print(f"Error starting eye tracking: {e}")
            self.active = False
            return False
            
    def stop(self) -> None:
        """Stop eye tracking"""
        self.active = False
        
        # Release camera if using OpenCV
        if CV2_AVAILABLE and self.camera is not None:
            self.camera.release()
            self.camera = None
            
        # Wait for threads to end
        if self.thread:
            self.thread.join(timeout=1.0)
            
        if self.tracking_thread:
            self.tracking_thread.join(timeout=1.0)
            
        # Save state before exiting
        self._save_state()
            
    def _tracking_thread(self) -> None:
        """Thread for camera capture and eye tracking"""
        if not CV2_AVAILABLE:
            return
            
        # Initialize camera
        try:
            self.camera = cv2.VideoCapture(CONFIG["camera_device"])
            self.camera.set(cv2.CAP_PROP_FRAME_WIDTH, self.frame_width)
            self.camera.set(cv2.CAP_PROP_FRAME_HEIGHT, self.frame_height)
        except Exception as e:
            print(f"Error initializing camera: {e}")
            self.active = False
            return
            
        # Main tracking loop
        while self.active:
            try:
                # Capture frame
                ret, frame = self.camera.read()
                if not ret:
                    time.sleep(0.1)
                    continue
                    
                # Store frame for processing
                self.last_frame = frame
                
                # Sleep to control capture rate
                time.sleep(CONFIG["detection_interval"])
            except Exception as e:
                print(f"Error in tracking thread: {e}")
                time.sleep(0.5)
                
    def _processing_thread(self) -> None:
        """Thread for processing captured frames"""
        last_processing_time = time.time()
        
        while self.active:
            current_time = time.time()
            
            # Skip if no frame available or not enough time passed
            if (self.last_frame is None or 
                current_time - last_processing_time < CONFIG["detection_interval"]):
                time.sleep(0.01)
                continue
                
            # Process frame
            try:
                self._process_frame(self.last_frame)
                last_processing_time = current_time
                
                # Decay focus map
                self.focus_map.decay()
                
                # Save periodically
                if current_time - self.last_save >= CONFIG["save_interval"]:
                    self._save_state()
                    self.last_save = current_time
                    
                # Limit history size
                if len(self.state_history) > CONFIG["max_history_items"]:
                    self.state_history = self.state_history[-CONFIG["max_history_items"]:]
                    
            except Exception as e:
                print(f"Error in processing thread: {e}")
                
            # Sleep to reduce CPU usage
            time.sleep(0.01)
            
    def _simulation_thread(self) -> None:
        """Thread for simulated eye tracking when in offline mode"""
        # Simulation parameters
        gaze_x, gaze_y = 0.5, 0.5  # Start at center
        target_x, target_y = 0.5, 0.5
        speed = 0.1
        
        last_target_change = time.time()
        last_blink = time.time()
        last_process = time.time()
        
        while self.active:
            current_time = time.time()
            
            # Change target randomly
            if current_time - last_target_change > random.uniform(0.5, 3.0):
                # 80% chance to pick a random point, 20% chance to focus on a pattern
                if random.random() < 0.8:
                    target_x = random.uniform(0.1, 0.9)
                    target_y = random.uniform(0.1, 0.9)
                else:
                    # Create a pattern like reading text or scanning a grid
                    pattern_type = random.choice(["read", "scan", "focus"])
                    
                    if pattern_type == "read":
                        # Simulate reading lines of text
                        target_y = random.uniform(0.2, 0.8)
                        target_x = 0.1  # Start at left
                    elif pattern_type == "scan":
                        # Simulate scanning a grid
                        grid_x = random.randint(0, 3)
                        grid_y = random.randint(0, 2)
                        target_x = 0.2 + grid_x * 0.2
                        target_y = 0.3 + grid_y * 0.2
                    else:  # focus
                        # Stay near current position
                        target_x = min(0.9, max(0.1, gaze_x + random.uniform(-0.1, 0.1)))
                        target_y = min(0.9, max(0.1, gaze_y + random.uniform(-0.1, 0.1)))
                        
                last_target_change = current_time
                
            # Move gaze toward target
            dx = target_x - gaze_x
            dy = target_y - gaze_y
            distance = (dx**2 + dy**2) ** 0.5
            
            if distance > 0.01:
                # Move toward target
                gaze_x += dx * speed
                gaze_y += dy * speed
            else:
                # Slight random movement when at target
                gaze_x += random.uniform(-0.01, 0.01)
                gaze_y += random.uniform(-0.01, 0.01)
                
                # Clamp to valid range
                gaze_x = min(0.99, max(0.01, gaze_x))
                gaze_y = min(0.99, max(0.01, gaze_y))
                
            # Simulate blinks
            blink_detected = False
            if current_time - last_blink > random.uniform(2.0, 5.0):
                blink_detected = True
                last_blink = current_time
                
            # Only process simulated data at intervals
            if current_time - last_process >= CONFIG["detection_interval"]:
                # Create eye state
                state = EyeState()
                state.left_open = not blink_detected
                state.right_open = not blink_detected
                state.left_position = (gaze_x, gaze_y)
                state.right_position = (gaze_x, gaze_y)
                state.gaze_point = (gaze_x, gaze_y)
                state.blink_detected = blink_detected
                state.timestamp = current_time
                state.confidence = random.uniform(0.7, 0.95)  # Simulated confidence
                
                # Convert to screen coordinates
                state.screen_point = (
                    int(gaze_x * self.screen_width),
                    int(gaze_y * self.screen_height)
                )
                
                # If reading pattern, simulate saccades sometimes
                if target_x == 0.1 and random.random() < 0.3:
                    state.saccade_detected = True
                    target_x = random.uniform(0.1, 0.9)  # Jump to next line
                    
                # Update current state and history
                self.current_state = state
                self.state_history.append(state)
                
                # Update focus map
                self.focus_map.update(state.gaze_point)
                
                # Get focus regions
                self.focus_regions = self.focus_map.get_focus_regions()
                
                # Check for split attention
                self.split_attention = self.focus_map.get_split_attention()
                
                # Update counters
                self.detection_counter += 1
                if blink_detected:
                    self.blink_counter += 1
                    
                # For reading pattern, increment after processing
                if target_x == 0.1:
                    target_x += 0.05  # Move right along the line
                    if target_x > 0.9:  # End of line
                        target_x = 0.1  # Return to start
                        target_y += 0.05  # Move down to next line
                        if target_y > 0.8:  # Bottom of text
                            target_y = 0.2  # Back to top
                
                # Add reasons sometimes
                if random.random() < 0.1:  # 10% chance
                    reason_type = random.choice(list(FocusReason.REASON_TYPES.keys()))
                    self._add_reason(reason_type)
                    
                last_process = current_time
                
            # Sleep to reduce CPU usage
            time.sleep(0.01)
            
    def _process_frame(self, frame) -> None:
        """Process a captured frame to detect eyes and gaze"""
        if not CV2_AVAILABLE or self.face_cascade is None or self.eye_cascade is None:
            return
            
        # Convert to grayscale
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Detect faces
        faces = self.face_cascade.detectMultiScale(
            gray,
            scaleFactor=1.1,
            minNeighbors=5,
            minSize=(30, 30)
        )
        
        # If no faces detected, return with lower confidence
        if len(faces) == 0:
            self.current_state.confidence = 0.1
            return
            
        # Process the largest face
        face = max(faces, key=lambda f: f[2] * f[3])
        x, y, w, h = face
        
        # Get region of interest for the face
        roi_gray = gray[y:y+h, x:x+w]
        
        # Detect eyes
        eyes = self.eye_cascade.detectMultiScale(
            roi_gray,
            scaleFactor=1.1,
            minNeighbors=5,
            minSize=(20, 20)
        )
        
        # If no eyes detected, assume blink
        if len(eyes) == 0:
            self.current_state.left_open = False
            self.current_state.right_open = False
            self.current_state.blink_detected = True
            self.current_state.confidence = 0.5
            self.blink_counter += 1
            return
            
        # Process detected eyes
        eye_states = []
        for ex, ey, ew, eh in eyes:
            # Calculate normalized position (0.0-1.0)
            center_x = (x + ex + ew/2) / self.frame_width
            center_y = (y + ey + eh/2) / self.frame_height
            
            # Add to eye states
            eye_states.append((center_x, center_y))
            
            # In debug mode, draw on frame if enabled
            if CONFIG["debug_mode"] and not CONFIG["privacy_mode"]:
                cv2.rectangle(frame, (x+ex, y+ey), (x+ex+ew, y+ey+eh), (0, 255, 0), 2)
                
        # Update current state based on detected eyes
        if len(eye_states) >= 2:
            # Assume the leftmost eye is left eye and rightmost is right eye
            eye_states.sort(key=lambda e: e[0])
            self.current_state.left_position = eye_states[0]
            self.current_state.right_position = eye_states[1]
            self.current_state.left_open = True
            self.current_state.right_open = True
        elif len(eye_states) == 1:
            # Single eye detected, use heuristic to determine which one
            if eye_states[0][0] < 0.5:
                self.current_state.left_position = eye_states[0]
                self.current_state.left_open = True
                self.current_state.right_open = False
            else:
                self.current_state.right_position = eye_states[0]
                self.current_state.left_open = False
                self.current_state.right_open = True
                
        # Calculate gaze point (average of detected eyes)
        gaze_x = sum(e[0] for e in eye_states) / len(eye_states)
        gaze_y = sum(e[1] for e in eye_states) / len(eye_states)
        self.current_state.gaze_point = (gaze_x, gaze_y)
        
        # Convert to screen coordinates
        screen_x = int(gaze_x * self.screen_width)
        screen_y = int(gaze_y * self.screen_height)
        self.current_state.screen_point = (screen_x, screen_y)
        
        # Set timestamp and confidence
        self.current_state.timestamp = time.time()
        self.current_state.confidence = min(0.9, 0.5 + 0.1 * len(eye_states))
        self.current_state.blink_detected = False
        
        # Compare with previous state to detect saccades
        if len(self.state_history) > 0:
            prev_gaze = self.state_history[-1].gaze_point
            distance = ((gaze_x - prev_gaze[0])**2 + (gaze_y - prev_gaze[1])**2) ** 0.5
            
            # Detect quick eye movements
            if distance > 0.05:  # Threshold for saccade detection
                self.current_state.saccade_detected = True
                
        # Add to history
        self.state_history.append(self.current_state)
        
        # Update focus map
        self.focus_map.update(self.current_state.gaze_point)
        
        # Update focus regions
        self.focus_regions = self.focus_map.get_focus_regions()
        
        # Check for split attention
        self.split_attention = self.focus_map.get_split_attention()
        
        # Update counter
        self.detection_counter += 1
        
    def calibrate(self, screen_width: int, screen_height: int) -> bool:
        """Calibrate eye tracking to screen coordinates"""
        self.screen_width = screen_width
        self.screen_height = screen_height
        
        if self.offline_mode:
            # No real calibration needed in offline mode
            self.calibrated = True
            return True
            
        # Real calibration would require user interaction with UI
        # This is a simplified version
        self.calibration_points = []
        
        # Define calibration points (corners and center)
        points = [
            (0.1, 0.1),  # Top-left
            (0.9, 0.1),  # Top-right
            (0.5, 0.5),  # Center
            (0.1, 0.9),  # Bottom-left
            (0.9, 0.9)   # Bottom-right
        ]
        
        # In a real application, each point would require user focus
        # Here we'll just simulate it
        for i, (x, y) in enumerate(points):
            # Create a calibration point
            screen_x = int(x * screen_width)
            screen_y = int(y * screen_height)
            
            self.calibration_points.append({
                "screen_pos": (screen_x, screen_y),
                "normalized_pos": (x, y),
                "gaze_pos": (x, y)  # In simulation, use the same position
            })
            
        self.calibrated = True
        return True
        
    def _add_reason(self, reason_type: str, description: str = "", confidence: float = 0.7) -> None:
        """Add a reason for focus change"""
        if not CONFIG["reason_collection_enabled"]:
            return
            
        reason = FocusReason(reason_type, description, confidence)
        
        # Associate with current state
        if len(self.state_history) > 0:
            reason.associated_states.append(self.state_history[-1].timestamp)
            
        self.reasons.append(reason)
        
    def get_current_state(self) -> EyeState:
        """Get the current eye tracking state"""
        return self.current_state
        
    def get_state_history(self, count: int = 10) -> List[EyeState]:
        """Get recent eye tracking history"""
        return self.state_history[-count:]
        
    def get_focus_pattern(self) -> str:
        """Get the current focus pattern as text"""
        return self.focus_map.get_focus_pattern()
        
    def get_status(self) -> Dict[str, Any]:
        """Get eye tracker status"""
        return {
            "active": self.active,
            "mode": "offline" if self.offline_mode else "camera",
            "detections": self.detection_counter,
            "blinks": self.blink_counter,
            "calibrated": self.calibrated,
            "confidence": self.current_state.confidence,
            "gaze": self.current_state.gaze_point,
            "screen": self.current_state.screen_point,
            "split_attention": self.split_attention is not None,
            "focus_regions": len(self.focus_regions),
            "reasons": len(self.reasons)
        }
        
    def _save_state(self) -> bool:
        """Save eye tracking state to file"""
        try:
            # Save state history (keep it small to avoid huge files)
            with open("eye_tracker_state.json", "w") as f:
                data = {
                    "timestamp": datetime.now().isoformat(),
                    "mode": "offline" if self.offline_mode else "camera",
                    "detections": self.detection_counter,
                    "blinks": self.blink_counter,
                    "calibrated": self.calibrated,
                    "screen_dims": (self.screen_width, self.screen_height),
                    "last_state": self.current_state.to_dict(),
                    "history": [s.to_dict() for s in self.state_history[-50:]],  # Last 50 states
                    "reasons": [r.to_dict() for r in self.reasons[-20:]]  # Last 20 reasons
                }
                
                json.dump(data, f, indent=2)
                
            # Save focus map
            self.focus_map.save_to_file("eye_tracker_focus.json")
            return True
        except Exception as e:
            print(f"Error saving eye tracker state: {e}")
            return False
            
    def load_state(self) -> bool:
        """Load eye tracking state from file"""
        try:
            # Load state history
            if os.path.exists("eye_tracker_state.json"):
                with open("eye_tracker_state.json", "r") as f:
                    data = json.load(f)
                    
                # Restore state
                self.detection_counter = data.get("detections", 0)
                self.blink_counter = data.get("blinks", 0)
                self.calibrated = data.get("calibrated", False)
                self.screen_width, self.screen_height = data.get("screen_dims", (1920, 1080))
                
                # Restore last state
                if "last_state" in data:
                    self.current_state = EyeState.from_dict(data["last_state"])
                    
                # Restore history
                if "history" in data:
                    self.state_history = [EyeState.from_dict(s) for s in data["history"]]
                    
                # Restore reasons
                if "reasons" in data:
                    self.reasons = [FocusReason.from_dict(r) for r in data["reasons"]]
                    
            # Load focus map
            if os.path.exists("eye_tracker_focus.json"):
                self.focus_map.load_from_file("eye_tracker_focus.json")
                
            return True
        except Exception as e:
            print(f"Error loading eye tracker state: {e}")
            return False
            
    def integrate_with_console(self, 
                              console, 
                              reason_callback=None, 
                              split_callback=None) -> None:
        """Integrate eye tracking with console system"""
        # Check if console has necessary methods
        if not hasattr(console, "add_memory"):
            print("Console integration failed: missing add_memory method")
            return
            
        # Register callbacks
        self.reason_callback = reason_callback
        self.split_callback = split_callback
        
        # Load module-specific state if available
        if hasattr(console, "config") and "eye_tracking" in console.config:
            # Apply configuration
            etc = console.config["eye_tracking"]
            
            if "offline_mode" in etc:
                self.offline_mode = etc["offline_mode"]
                
            if "calibration" in etc and etc["calibration"]:
                self.calibration_points = etc["calibration"]
                self.calibrated = True
                
        # Add initial memory about eye tracking
        if self.offline_mode:
            console.add_memory(
                "Eye tracking system initialized in offline mode. "
                "Using simulated eye movement patterns.",
                tags=["#eye_tracking", "#simulation"]
            )
        else:
            console.add_memory(
                "Eye tracking system initialized with camera. "
                "Monitoring eye movements and attention patterns.",
                tags=["#eye_tracking", "#camera"]
            )
            
        # Start eye tracking if not already running
        if not self.active:
            self.start()

class OfflineConsole:
    """Simulates console functions when working offline"""
    
    def __init__(self):
        self.memory_items = []
        self.command_history = []
        self.split_mode = CONFIG["split_mode_enabled"]
        self.last_update = time.time()
        self.connected = False
        self.responses = []
        self.config = {
            "eye_tracking": {
                "offline_mode": True,
                "enabled": True
            }
        }
        
    def add_memory(self, content: str, tags: List[str] = None) -> None:
        """Add a memory item"""
        self.memory_items.append({
            "content": content,
            "tags": tags or [],
            "timestamp": datetime.now().isoformat()
        })
        
    def process_command(self, command: str) -> str:
        """Process a command in offline mode"""
        self.command_history.append(command)
        
        # Simulate responses
        responses = [
            "Processing command in offline mode...",
            "Command received and stored for later execution.",
            "Offline mode active, command will execute when online.",
            "Command queued in offline storage.",
            "Split processing mode applied to command."
        ]
        
        if self.split_mode:
            response = "SPLIT MODE: " + random.choice(responses)
        else:
            response = random.choice(responses)
            
        self.responses.append({
            "command": command,
            "response": response,
            "timestamp": datetime.now().isoformat()
        })
        
        return response
        
    def get_status(self) -> Dict[str, Any]:
        """Get offline console status"""
        return {
            "mode": "offline",
            "split_mode": self.split_mode,
            "memories": len(self.memory_items),
            "commands": len(self.command_history),
            "connected": self.connected,
            "uptime": time.time() - self.last_update
        }
        
def main():
    """Main function for testing eye tracking system"""
    # Initialize eye tracker
    print("Initializing eye tracking system...")
    tracker = EyeTracker()
    
    # Check for OpenCV
    if not CV2_AVAILABLE:
        print("OpenCV not available, using offline mode")
        CONFIG["offline_mode"] = True
        
    # Create offline console for testing
    console = OfflineConsole()
    
    # Integrate with console
    tracker.integrate_with_console(console)
    
    # Calibrate for screen size
    tracker.calibrate(1920, 1080)
    
    print("\nEye tracking system started:")
    print("- Mode:", "Offline" if tracker.offline_mode else "Camera")
    print("- Press 'q' to quit")
    print("- Press 's' to toggle split mode")
    print("- Press 'f' to show focus map")
    print("- Press 'r' to show recent reasons")
    
    # Main loop
    try:
        while True:
            # Get input (non-blocking)
            if os.name == 'nt':
                import msvcrt
                if msvcrt.kbhit():
                    key = msvcrt.getch().decode('utf-8').lower()
                else:
                    key = None
            else:
                import sys, tty, termios
                old_settings = termios.tcgetattr(sys.stdin)
                try:
                    tty.setcbreak(sys.stdin.fileno())
                    if sys.stdin.read(1):
                        key = sys.stdin.read(1).lower()
                    else:
                        key = None
                finally:
                    termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)
            
            # Process key
            if key == 'q':
                break
            elif key == 's':
                console.split_mode = not console.split_mode
                print(f"Split mode: {'Enabled' if console.split_mode else 'Disabled'}")
            elif key == 'f':
                print("\nFocus Map:")
                print(tracker.get_focus_pattern())
            elif key == 'r':
                print("\nRecent Reasons:")
                for i, reason in enumerate(tracker.reasons[-5:]):
                    print(f"{i+1}. {reason.reason_type}: {reason.description} ({reason.confidence:.2f})")
                    
            # Show status every 5 seconds
            if int(time.time()) % 5 == 0:
                state = tracker.get_current_state()
                print(f"\rGaze: ({state.gaze_point[0]:.2f}, {state.gaze_point[1]:.2f}), "
                      f"Blinks: {tracker.blink_counter}, "
                      f"Split: {'Yes' if tracker.split_attention else 'No'}", end='')
                      
            time.sleep(0.1)
            
    except KeyboardInterrupt:
        print("\nExiting...")
    finally:
        # Stop tracking
        tracker.stop()
        print("\nEye tracking system stopped")
        
        # Final report
        status = tracker.get_status()
        print(f"Total detections: {status['detections']}")
        print(f"Total blinks: {status['blinks']}")
        print(f"Focus regions: {status['focus_regions']}")
        print(f"Reasons collected: {status['reasons']}")

if __name__ == "__main__":
    main()