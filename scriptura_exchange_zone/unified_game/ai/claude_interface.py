#!/usr/bin/env python3
"""
Evolution Game Claude - Claude AI Interface
==========================================

Interface layer for integrating Claude AI with the evolution engine.
Provides advanced decision making and reasoning for game evolution.
"""

import json
import time
import random
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime

from evolution_engine import GameEntity, EvolutionEngine, EvolutionParams


@dataclass
class ClaudeDecision:
    """Represents a decision made by Claude AI."""
    decision_type: str
    reasoning: str
    confidence: float
    parameters: Dict[str, Any]
    timestamp: str
    thinking_mode: str = "think"


class ClaudeInterface:
    """
    Interface for Claude AI integration with the evolution system.
    
    This class simulates Claude AI decision making and will be enhanced
    with actual Claude API integration in future versions.
    """
    
    def __init__(self):
        self.decision_history: List[ClaudeDecision] = []
        self.thinking_modes = ["think", "think_hard", "think_harder", "ultrathink"]
        self.expertise_areas = [
            "game_balance",
            "player_psychology", 
            "evolutionary_algorithms",
            "emergent_behavior",
            "adaptive_systems"
        ]
        
        print("🤖 Claude AI Interface initialized")
        print("🧠 Available thinking modes:", ", ".join(self.thinking_modes))
        print("🎯 Expertise areas:", ", ".join(self.expertise_areas))
    
    def analyze_population(self, population: List[GameEntity], generation: int) -> Dict[str, Any]:
        """
        Analyze the current population and provide insights.
        
        This simulates Claude's analytical capabilities for understanding
        the evolutionary state and making recommendations.
        """
        thinking_mode = self._select_thinking_mode("population_analysis")
        
        print(f"\n🧠 Claude analyzing population (mode: {thinking_mode})")
        
        # Simulate Claude's analysis process
        time.sleep(0.5)  # Thinking time
        
        # Calculate population statistics
        fitness_values = [entity.fitness for entity in population]
        trait_averages = {}
        
        if population:
            trait_names = list(population[0].traits.keys())
            for trait in trait_names:
                trait_averages[trait] = sum(entity.traits[trait] for entity in population) / len(population)
        
        # Simulate Claude's insights
        diversity_score = self._calculate_diversity(population)
        stagnation_risk = self._assess_stagnation_risk(generation)
        
        analysis = {
            "generation": generation,
            "population_size": len(population),
            "fitness_stats": {
                "min": min(fitness_values) if fitness_values else 0,
                "max": max(fitness_values) if fitness_values else 0,
                "avg": sum(fitness_values) / len(fitness_values) if fitness_values else 0,
                "std": self._calculate_std(fitness_values)
            },
            "trait_averages": trait_averages,
            "diversity_score": diversity_score,
            "stagnation_risk": stagnation_risk,
            "recommendations": self._generate_recommendations(diversity_score, stagnation_risk),
            "thinking_mode": thinking_mode
        }
        
        print(f"📊 Population analysis complete")
        print(f"🎯 Diversity score: {diversity_score:.3f}")
        print(f"⚠️  Stagnation risk: {stagnation_risk:.3f}")
        
        return analysis
    
    def suggest_evolution_parameters(self, current_params: EvolutionParams, 
                                   analysis: Dict[str, Any]) -> EvolutionParams:
        """
        Suggest optimal evolution parameters based on population analysis.
        
        This demonstrates Claude's ability to adaptively tune the evolution
        process for better outcomes.
        """
        thinking_mode = self._select_thinking_mode("parameter_optimization")
        
        print(f"\n🔧 Claude optimizing parameters (mode: {thinking_mode})")
        
        # Start with current parameters
        new_params = EvolutionParams(
            population_size=current_params.population_size,
            mutation_rate=current_params.mutation_rate,
            crossover_rate=current_params.crossover_rate,
            elite_size=current_params.elite_size,
            max_generations=current_params.max_generations,
            fitness_threshold=current_params.fitness_threshold
        )
        
        # Claude's adaptive parameter suggestions
        diversity_score = analysis.get("diversity_score", 0.5)
        stagnation_risk = analysis.get("stagnation_risk", 0.5)
        
        reasoning_points = []
        
        # Adjust mutation rate based on diversity
        if diversity_score < 0.3:
            new_params.mutation_rate = min(0.3, current_params.mutation_rate * 1.5)
            reasoning_points.append("Increased mutation rate to promote diversity")
        elif diversity_score > 0.8:
            new_params.mutation_rate = max(0.05, current_params.mutation_rate * 0.8)
            reasoning_points.append("Decreased mutation rate to preserve good solutions")
        
        # Adjust crossover rate based on stagnation
        if stagnation_risk > 0.7:
            new_params.crossover_rate = min(0.9, current_params.crossover_rate * 1.2)
            reasoning_points.append("Increased crossover rate to combat stagnation")
        
        # Adjust elite size based on population performance
        fitness_std = analysis.get("fitness_stats", {}).get("std", 0)
        if fitness_std < 0.1:  # Low variance, increase elitism
            new_params.elite_size = min(10, current_params.elite_size + 2)
            reasoning_points.append("Increased elite size due to low fitness variance")
        
        # Record decision
        decision = ClaudeDecision(
            decision_type="parameter_optimization",
            reasoning="; ".join(reasoning_points),
            confidence=0.8,
            parameters={
                "old_mutation_rate": current_params.mutation_rate,
                "new_mutation_rate": new_params.mutation_rate,
                "old_crossover_rate": current_params.crossover_rate,
                "new_crossover_rate": new_params.crossover_rate,
                "old_elite_size": current_params.elite_size,
                "new_elite_size": new_params.elite_size
            },
            timestamp=datetime.now().isoformat(),
            thinking_mode=thinking_mode
        )
        
        self.decision_history.append(decision)
        
        print(f"✅ Parameter optimization complete")
        if reasoning_points:
            print("🎯 Adjustments made:")
            for point in reasoning_points:
                print(f"  • {point}")
        
        return new_params
    
    def evaluate_fitness_criteria(self, entity: GameEntity, 
                                 game_state: Dict[str, Any]) -> float:
        """
        Enhanced fitness evaluation using Claude's understanding of game design.
        
        This provides more sophisticated fitness evaluation than basic algorithms.
        """
        thinking_mode = self._select_thinking_mode("fitness_evaluation")
        
        # Base fitness from traits
        base_fitness = self._calculate_base_fitness(entity)
        
        # Claude's enhanced evaluation factors
        
        # 1. Balance assessment - entities shouldn't be too extreme
        balance_score = self._assess_balance(entity)
        
        # 2. Novelty assessment - reward unique combinations
        novelty_score = self._assess_novelty(entity, game_state)
        
        # 3. Potential assessment - future evolution promise
        potential_score = self._assess_potential(entity)
        
        # 4. Player experience prediction
        experience_score = self._predict_player_experience(entity)
        
        # Weighted combination (Claude's expertise)
        enhanced_fitness = (
            0.4 * base_fitness +
            0.2 * balance_score +
            0.2 * novelty_score +
            0.1 * potential_score +
            0.1 * experience_score
        )
        
        # Record decision for learning
        decision = ClaudeDecision(
            decision_type="fitness_evaluation",
            reasoning=f"Enhanced fitness: base={base_fitness:.3f}, balance={balance_score:.3f}, novelty={novelty_score:.3f}",
            confidence=0.7,
            parameters={
                "base_fitness": base_fitness,
                "balance_score": balance_score,
                "novelty_score": novelty_score,
                "potential_score": potential_score,
                "experience_score": experience_score,
                "final_fitness": enhanced_fitness
            },
            timestamp=datetime.now().isoformat(),
            thinking_mode=thinking_mode
        )
        
        return max(0.0, min(1.0, enhanced_fitness))
    
    def predict_emergence(self, population: List[GameEntity]) -> Dict[str, Any]:
        """
        Predict potential emergent behaviors from current population.
        
        This showcases Claude's ability to anticipate complex system behaviors.
        """
        thinking_mode = "ultrathink"  # Use maximum thinking power
        
        print(f"\n🔮 Claude predicting emergence (mode: {thinking_mode})")
        time.sleep(1.0)  # Deep thinking simulation
        
        # Analyze trait correlations
        correlations = self._analyze_trait_correlations(population)
        
        # Identify potential emergence patterns
        emergence_patterns = []
        
        # Pattern 1: Specialization emergence
        trait_specialization = self._detect_specialization(population)
        if trait_specialization:
            emergence_patterns.append({
                "type": "specialization",
                "description": "Population showing specialization into distinct archetypes",
                "traits_involved": trait_specialization,
                "probability": 0.7
            })
        
        # Pattern 2: Cooperation emergence
        cooperation_potential = self._detect_cooperation_potential(population)
        if cooperation_potential > 0.6:
            emergence_patterns.append({
                "type": "cooperation",
                "description": "High potential for cooperative behaviors to emerge",
                "cooperation_score": cooperation_potential,
                "probability": 0.6
            })
        
        # Pattern 3: Arms race emergence
        competition_pressure = self._detect_competition_pressure(population)
        if competition_pressure > 0.7:
            emergence_patterns.append({
                "type": "arms_race",
                "description": "Competitive pressure may lead to rapid trait escalation",
                "competition_score": competition_pressure,
                "probability": 0.5
            })
        
        prediction = {
            "timestamp": datetime.now().isoformat(),
            "generation": len(population),
            "emergence_patterns": emergence_patterns,
            "trait_correlations": correlations,
            "confidence": 0.6,
            "thinking_mode": thinking_mode
        }
        
        print(f"🔮 Emergence prediction complete")
        print(f"📊 Found {len(emergence_patterns)} potential patterns")
        
        return prediction
    
    def _select_thinking_mode(self, task_type: str) -> str:
        """Select appropriate thinking mode based on task complexity."""
        complexity_map = {
            "population_analysis": "think_hard",
            "parameter_optimization": "think_harder", 
            "fitness_evaluation": "think",
            "emergence_prediction": "ultrathink",
            "game_balance": "think_harder"
        }
        
        return complexity_map.get(task_type, "think")
    
    def _calculate_diversity(self, population: List[GameEntity]) -> float:
        """Calculate population diversity score."""
        if len(population) < 2:
            return 0.0
        
        # Calculate average pairwise distance in trait space
        total_distance = 0
        pairs = 0
        
        for i in range(len(population)):
            for j in range(i + 1, len(population)):
                distance = 0
                for trait in population[i].traits:
                    distance += (population[i].traits[trait] - population[j].traits[trait]) ** 2
                total_distance += distance ** 0.5
                pairs += 1
        
        return min(1.0, total_distance / pairs / 2.0)  # Normalize
    
    def _assess_stagnation_risk(self, generation: int) -> float:
        """Assess risk of evolutionary stagnation."""
        # Simple heuristic - higher risk with more generations
        # Real implementation would analyze fitness history
        base_risk = min(0.8, generation / 100)
        
        # Add some randomness for simulation
        noise = random.uniform(-0.1, 0.1)
        
        return max(0.0, min(1.0, base_risk + noise))
    
    def _generate_recommendations(self, diversity: float, stagnation: float) -> List[str]:
        """Generate recommendations based on analysis."""
        recommendations = []
        
        if diversity < 0.3:
            recommendations.append("Increase mutation rate to promote diversity")
        if stagnation > 0.7:
            recommendations.append("Consider introducing new genetic material")
        if diversity > 0.8 and stagnation < 0.3:
            recommendations.append("Current evolution is healthy, maintain parameters")
        
        return recommendations
    
    def _calculate_std(self, values: List[float]) -> float:
        """Calculate standard deviation."""
        if not values:
            return 0.0
        
        mean = sum(values) / len(values)
        variance = sum((x - mean) ** 2 for x in values) / len(values)
        return variance ** 0.5
    
    def _calculate_base_fitness(self, entity: GameEntity) -> float:
        """Calculate basic fitness from traits."""
        # Simple weighted sum
        weights = {
            "speed": 0.15,
            "agility": 0.1,
            "intelligence": 0.2,
            "cooperation": 0.15,
            "aggression": 0.1,
            "efficiency": 0.15,
            "adaptability": 0.1,
            "creativity": 0.05
        }
        
        fitness = 0
        for trait, value in entity.traits.items():
            weight = weights.get(trait, 0.1)
            fitness += weight * (value / 2.0)  # Normalize to 0-1
        
        return fitness
    
    def _assess_balance(self, entity: GameEntity) -> float:
        """Assess how balanced an entity's traits are."""
        values = list(entity.traits.values())
        mean_val = sum(values) / len(values)
        
        # Penalize extreme values
        balance_penalty = sum(abs(v - mean_val) for v in values) / len(values)
        
        return max(0.0, 1.0 - balance_penalty / 2.0)
    
    def _assess_novelty(self, entity: GameEntity, game_state: Dict[str, Any]) -> float:
        """Assess how novel this entity's trait combination is."""
        # Simplified novelty assessment
        # Real implementation would compare against historical data
        
        trait_sum = sum(entity.traits.values())
        novelty = abs(trait_sum - 8.0) / 8.0  # 8.0 is expected average
        
        return min(1.0, novelty)
    
    def _assess_potential(self, entity: GameEntity) -> float:
        """Assess potential for future evolution."""
        # Entities with moderate traits have more potential
        potential = 0
        for value in entity.traits.values():
            # Best potential around middle values
            potential += 1.0 - abs(value - 1.0)
        
        return potential / len(entity.traits)
    
    def _predict_player_experience(self, entity: GameEntity) -> float:
        """Predict how much players would enjoy this entity."""
        # Simplified player experience model
        # Real version would use player feedback data
        
        # Players tend to like balanced entities with some specialization
        balance = self._assess_balance(entity)
        specialization = max(entity.traits.values()) - min(entity.traits.values())
        
        experience = 0.6 * balance + 0.4 * min(1.0, specialization / 2.0)
        
        return experience
    
    def _analyze_trait_correlations(self, population: List[GameEntity]) -> Dict[str, float]:
        """Analyze correlations between traits in the population."""
        # Simplified correlation analysis
        correlations = {}
        
        if len(population) > 5:
            trait_names = list(population[0].traits.keys())
            
            for i, trait1 in enumerate(trait_names):
                for trait2 in trait_names[i+1:]:
                    # Calculate simple correlation
                    values1 = [e.traits[trait1] for e in population]
                    values2 = [e.traits[trait2] for e in population]
                    
                    correlation = self._simple_correlation(values1, values2)
                    correlations[f"{trait1}-{trait2}"] = correlation
        
        return correlations
    
    def _simple_correlation(self, x: List[float], y: List[float]) -> float:
        """Calculate simple correlation coefficient."""
        if len(x) != len(y) or len(x) < 2:
            return 0.0
        
        mean_x = sum(x) / len(x)
        mean_y = sum(y) / len(y)
        
        numerator = sum((x[i] - mean_x) * (y[i] - mean_y) for i in range(len(x)))
        
        sum_sq_x = sum((x[i] - mean_x) ** 2 for i in range(len(x)))
        sum_sq_y = sum((y[i] - mean_y) ** 2 for i in range(len(y)))
        
        denominator = (sum_sq_x * sum_sq_y) ** 0.5
        
        if denominator == 0:
            return 0.0
        
        return numerator / denominator
    
    def _detect_specialization(self, population: List[GameEntity]) -> List[str]:
        """Detect if population is specializing into archetypes."""
        specialized_traits = []
        
        trait_names = list(population[0].traits.keys())
        
        for trait in trait_names:
            values = [e.traits[trait] for e in population]
            std_dev = self._calculate_std(values)
            
            # High standard deviation indicates specialization
            if std_dev > 0.4:
                specialized_traits.append(trait)
        
        return specialized_traits
    
    def _detect_cooperation_potential(self, population: List[GameEntity]) -> float:
        """Detect potential for cooperative behaviors."""
        cooperation_values = [e.traits.get("cooperation", 0) for e in population]
        aggression_values = [e.traits.get("aggression", 0) for e in population]
        
        avg_cooperation = sum(cooperation_values) / len(cooperation_values)
        avg_aggression = sum(aggression_values) / len(aggression_values)
        
        # High cooperation, low aggression = high cooperation potential
        potential = (avg_cooperation - avg_aggression + 2) / 4  # Normalize
        
        return max(0.0, min(1.0, potential))
    
    def _detect_competition_pressure(self, population: List[GameEntity]) -> float:
        """Detect competitive pressure in population."""
        fitness_values = [e.fitness for e in population if e.fitness > 0]
        
        if not fitness_values:
            return 0.0
        
        # High fitness variance indicates competitive pressure
        std_dev = self._calculate_std(fitness_values)
        mean_fitness = sum(fitness_values) / len(fitness_values)
        
        # Normalize by mean to get relative pressure
        pressure = std_dev / max(0.1, mean_fitness)
        
        return min(1.0, pressure)


def main():
    """Demo of Claude AI interface with evolution engine."""
    print("🤖 Evolution Game Claude - AI Interface Demo")
    print("=" * 50)
    
    # Initialize Claude interface
    claude = ClaudeInterface()
    
    # Create evolution engine
    config = EvolutionParams(
        population_size=20,
        mutation_rate=0.1,
        max_generations=10
    )
    
    engine = EvolutionEngine(config)
    engine.create_initial_population()
    
    # Demo Claude analysis
    analysis = claude.analyze_population(engine.population, engine.generation)
    
    # Demo parameter optimization
    new_params = claude.suggest_evolution_parameters(config, analysis)
    
    print(f"\n🔧 Parameter changes suggested:")
    print(f"  Mutation rate: {config.mutation_rate:.3f} → {new_params.mutation_rate:.3f}")
    print(f"  Crossover rate: {config.crossover_rate:.3f} → {new_params.crossover_rate:.3f}")
    print(f"  Elite size: {config.elite_size} → {new_params.elite_size}")
    
    # Demo emergence prediction
    emergence = claude.predict_emergence(engine.population)
    
    print(f"\n🔮 Emergence patterns detected: {len(emergence['emergence_patterns'])}")
    for pattern in emergence['emergence_patterns']:
        print(f"  • {pattern['type']}: {pattern['description']} (p={pattern['probability']:.2f})")
    
    print(f"\n📊 Claude AI Interface demo complete")
    print(f"🧠 Total decisions made: {len(claude.decision_history)}")


if __name__ == "__main__":
    main()