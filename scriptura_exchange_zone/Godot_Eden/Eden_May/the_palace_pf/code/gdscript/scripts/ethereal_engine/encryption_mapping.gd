# encryption_mapping.gd
extends Node

# The 25 special characters used in the game data
const SPECIAL_CHARS = [
	"α", "β", "γ", "δ", "ε", 
	"ζ", "η", "θ", "ι", "κ", 
	"λ", "μ", "ν", "ξ", "ο", 
	"π", "ρ", "σ", "τ", "υ", 
	"φ", "χ", "ψ", "ω", "Σ"
]

# Mapping to two-letter Romanji representations
const ROMANJI_MAPPING = {
	"α": "ka", "β": "ki", "γ": "ku", "δ": "ke", "ε": "ko",
	"ζ": "sa", "η": "shi", "θ": "su", "ι": "se", "κ": "so",
	"λ": "ta", "μ": "chi", "ν": "tsu", "ξ": "te", "ο": "to",
	"π": "na", "ρ": "ni", "σ": "nu", "τ": "ne", "υ": "no",
	"φ": "ha", "χ": "hi", "ψ": "fu", "ω": "he", "Σ": "ho"
}

# Reverse mapping (for decryption)
const REVERSE_MAPPING = {
	"ka": "α", "ki": "β", "ku": "γ", "ke": "δ", "ko": "ε",
	"sa": "ζ", "shi": "η", "su": "θ", "se": "ι", "so": "κ",
	"ta": "λ", "chi": "μ", "tsu": "ν", "te": "ξ", "to": "ο",
	"na": "π", "ni": "ρ", "nu": "σ", "ne": "τ", "no": "υ",
	"ha": "φ", "hi": "χ", "fu": "ψ", "he": "ω", "ho": "Σ"
}
