#!/usr/bin/env python3
"""
Simple OCR and data processing tool
"""
import sys
import os
import argparse
from datetime import datetime

def main():
    parser = argparse.ArgumentParser(description="OCR and Text Processing Tool")
    parser.add_argument("-i", "--image", help="Path to image for OCR")
    parser.add_argument("-t", "--text", help="Text to process")
    parser.add_argument("-o", "--output", help="Output file path")
    parser.add_argument("--summary", action="store_true", help="Summarize the text")
    parser.add_argument("--keywords", action="store_true", help="Extract keywords")
    args = parser.parse_args()
    
    # Print banner
    print("=" * 50)
    print("OCR and Text Processing Tool")
    print("=" * 50)
    
    # Check if OCR libraries are available
    try_tesseract = False
    try_easyocr = False
    
    try:
        import pytesseract
        try_tesseract = True
        print("[√] Tesseract OCR available")
    except ImportError:
        print("[X] Tesseract OCR not available")
    
    try:
        import easyocr
        try_easyocr = True
        print("[√] EasyOCR available")
    except ImportError:
        print("[X] EasyOCR not available")
    
    # Process image if provided
    if args.image:
        if os.path.exists(args.image):
            print(f"Processing image: {args.image}")
            text = perform_ocr(args.image, try_tesseract, try_easyocr)
            if text:
                print(f"Extracted text ({len(text)} characters)")
                if args.output:
                    with open(args.output, 'w') as f:
                        f.write(text)
                    print(f"Text saved to {args.output}")
                else:
                    print("First 200 characters:")
                    print(text[:200] + "..." if len(text) > 200 else text)
            else:
                print("No text extracted or OCR failed")
        else:
            print(f"Error: Image file not found: {args.image}")
    
    # Process text if provided
    if args.text:
        print(f"Processing text: {args.text[:30]}..." if len(args.text) > 30 else args.text)
        if args.summary:
            summary = summarize_text(args.text)
            print("Summary:", summary)
        if args.keywords:
            keywords = extract_keywords(args.text)
            print("Keywords:", keywords)

def perform_ocr(image_path, try_tesseract, try_easyocr):
    """Attempt OCR using available libraries"""
    text = ""
    
    # Try Tesseract
    if try_tesseract:
        try:
            import pytesseract
            from PIL import Image
            print("Using Tesseract OCR...")
            text = pytesseract.image_to_string(Image.open(image_path))
            if text.strip():
                return text
        except Exception as e:
            print(f"Tesseract OCR error: {e}")
    
    # Try EasyOCR
    if try_easyocr:
        try:
            import easyocr
            print("Using EasyOCR...")
            reader = easyocr.Reader(['en'])
            results = reader.readtext(image_path)
            text = " ".join([result[1] for result in results])
            return text
        except Exception as e:
            print(f"EasyOCR error: {e}")
    
    return None

def summarize_text(text):
    """Basic text summarization"""
    # Here we would implement more advanced summarization
    # For now, just return first 100 characters
    words = text.split()
    if len(words) <= 10:
        return text
    return " ".join(words[:10]) + "..."

def extract_keywords(text):
    """Simple keyword extraction"""
    # Basic implementation - remove common words
    common_words = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'with', 'by', 'is', 'are', 'was', 'were'}
    words = text.lower().split()
    keywords = [word for word in words if word not in common_words and len(word) > 3]
    # Count occurrences
    from collections import Counter
    counts = Counter(keywords)
    # Return top 5 keywords
    return [word for word, count in counts.most_common(5)]

if __name__ == "__main__":
    main()