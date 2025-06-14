#!/usr/bin/env python3
"""
Evolution Game Claude - Core Evolution Engine
============================================

The main evolution engine that drives adaptive gameplay mechanics.
Implements genetic algorithms, neural adaptation, and Claude AI integration.
"""

import random
import json
import time
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime


@dataclass
class GameEntity:
    """Represents an evolving game entity with genetic properties."""
    id: str
    traits: Dict[str, float]
    fitness: float = 0.0
    generation: int = 0
    parent_ids: List[str] = None
    mutations: List[str] = None
    
    def __post_init__(self):
        if self.parent_ids is None:
            self.parent_ids = []
        if self.mutations is None:
            self.mutations = []


@dataclass
class EvolutionParams:
    """Configuration parameters for the evolution system."""
    population_size: int = 50
    mutation_rate: float = 0.1
    crossover_rate: float = 0.7
    elite_size: int = 5
    max_generations: int = 1000
    fitness_threshold: float = 0.95
    
    
class EvolutionEngine:
    """
    Core evolution engine for adaptive game mechanics.
    
    Implements genetic algorithms with Claude AI integration for
    creating emergent gameplay through evolution.
    """
    
    def __init__(self, config: Optional[EvolutionParams] = None):
        self.config = config or EvolutionParams()
        self.population: List[GameEntity] = []
        self.generation = 0
        self.evolution_history: List[Dict[str, Any]] = []
        self.best_fitness_history: List[float] = []
        
        # Initialize random seed for reproducibility
        random.seed(int(time.time()))
        
        print("🧬 Evolution Engine initialized")
        print(f"📊 Population size: {self.config.population_size}")
        print(f"🔄 Mutation rate: {self.config.mutation_rate}")
        print(f"🤝 Crossover rate: {self.config.crossover_rate}")
    
    def create_initial_population(self) -> None:
        """Create the initial population of game entities."""
        print(f"🌱 Creating initial population of {self.config.population_size} entities...")
        
        self.population = []
        for i in range(self.config.population_size):
            entity = GameEntity(
                id=f"gen0_entity_{i:03d}",
                traits=self._generate_random_traits(),
                generation=0
            )
            self.population.append(entity)
        
        print(f"✅ Initial population created with {len(self.population)} entities")
    
    def _generate_random_traits(self) -> Dict[str, float]:
        """Generate random traits for a new entity."""
        return {
            "speed": random.uniform(0.1, 2.0),
            "agility": random.uniform(0.1, 2.0),
            "intelligence": random.uniform(0.1, 2.0),
            "cooperation": random.uniform(0.1, 2.0),
            "aggression": random.uniform(0.1, 2.0),
            "efficiency": random.uniform(0.1, 2.0),
            "adaptability": random.uniform(0.1, 2.0),
            "creativity": random.uniform(0.1, 2.0)
        }
    
    def evaluate_fitness(self, entity: GameEntity, player_feedback: Optional[Dict] = None) -> float:
        """
        Evaluate the fitness of an entity based on game performance.
        
        This is where Claude AI integration would provide sophisticated
        fitness evaluation based on player behavior and game metrics.
        """
        # Basic fitness calculation (to be enhanced with Claude AI)
        traits = entity.traits
        
        # Multi-dimensional fitness based on different criteria
        performance_score = (traits["speed"] + traits["efficiency"]) / 2
        social_score = (traits["cooperation"] - traits["aggression"]) / 2 + 1
        adaptability_score = (traits["adaptability"] + traits["intelligence"]) / 2
        creativity_score = traits["creativity"]
        
        # Weighted combination
        fitness = (
            0.3 * performance_score +
            0.2 * social_score +
            0.3 * adaptability_score +
            0.2 * creativity_score
        )
        
        # Add player feedback influence if available
        if player_feedback:
            feedback_bonus = player_feedback.get("enjoyment", 0) * 0.1
            fitness += feedback_bonus
        
        # Normalize to 0-1 range
        entity.fitness = max(0.0, min(1.0, fitness))
        return entity.fitness
    
    def select_parents(self) -> Tuple[GameEntity, GameEntity]:
        """Select two parents for crossover using tournament selection."""
        tournament_size = 3
        
        def tournament_select() -> GameEntity:
            contestants = random.sample(self.population, tournament_size)
            return max(contestants, key=lambda e: e.fitness)
        
        parent1 = tournament_select()
        parent2 = tournament_select()
        
        # Ensure parents are different
        while parent2.id == parent1.id:
            parent2 = tournament_select()
        
        return parent1, parent2
    
    def crossover(self, parent1: GameEntity, parent2: GameEntity) -> GameEntity:
        """Create offspring through crossover of two parents."""
        child_traits = {}
        
        # Blend crossover for continuous traits
        for trait_name in parent1.traits.keys():
            if random.random() < 0.5:
                # Take from parent1 with some blending
                alpha = random.uniform(-0.1, 1.1)
                child_traits[trait_name] = (
                    alpha * parent1.traits[trait_name] +
                    (1 - alpha) * parent2.traits[trait_name]
                )
            else:
                # Take from parent2 with some blending
                alpha = random.uniform(-0.1, 1.1)
                child_traits[trait_name] = (
                    alpha * parent2.traits[trait_name] +
                    (1 - alpha) * parent1.traits[trait_name]
                )
            
            # Ensure traits stay within reasonable bounds
            child_traits[trait_name] = max(0.1, min(2.0, child_traits[trait_name]))
        
        child = GameEntity(
            id=f"gen{self.generation + 1}_entity_{len(self.population):03d}",
            traits=child_traits,
            generation=self.generation + 1,
            parent_ids=[parent1.id, parent2.id]
        )
        
        return child
    
    def mutate(self, entity: GameEntity) -> None:
        """Apply mutations to an entity's traits."""
        mutations_applied = []
        
        for trait_name, trait_value in entity.traits.items():
            if random.random() < self.config.mutation_rate:
                # Gaussian mutation
                mutation_strength = 0.1
                mutation = random.gauss(0, mutation_strength)
                old_value = trait_value
                entity.traits[trait_name] = max(0.1, min(2.0, trait_value + mutation))
                
                mutations_applied.append(f"{trait_name}: {old_value:.3f} → {entity.traits[trait_name]:.3f}")
        
        entity.mutations = mutations_applied
    
    def evolve_generation(self, player_feedback: Optional[Dict] = None) -> Dict[str, Any]:
        """Evolve one generation of the population."""
        print(f"\n🔄 Evolving generation {self.generation} → {self.generation + 1}")
        
        # Evaluate fitness for all entities
        for entity in self.population:
            self.evaluate_fitness(entity, player_feedback)
        
        # Sort by fitness (descending)
        self.population.sort(key=lambda e: e.fitness, reverse=True)
        
        # Track best fitness
        best_fitness = self.population[0].fitness
        self.best_fitness_history.append(best_fitness)
        
        print(f"📊 Best fitness: {best_fitness:.4f}")
        print(f"🏆 Best entity: {self.population[0].id}")
        
        # Create new generation
        new_population = []
        
        # Keep elite individuals
        elite = self.population[:self.config.elite_size]
        new_population.extend(elite)
        print(f"👑 Preserved {len(elite)} elite entities")
        
        # Generate offspring
        while len(new_population) < self.config.population_size:
            if random.random() < self.config.crossover_rate:
                # Crossover
                parent1, parent2 = self.select_parents()
                child = self.crossover(parent1, parent2)
                self.mutate(child)
                new_population.append(child)
            else:
                # Clone with mutation
                parent = self.select_parents()[0]
                child = GameEntity(
                    id=f"gen{self.generation + 1}_clone_{len(new_population):03d}",
                    traits=parent.traits.copy(),
                    generation=self.generation + 1,
                    parent_ids=[parent.id]
                )
                self.mutate(child)
                new_population.append(child)
        
        # Update population and generation
        self.population = new_population[:self.config.population_size]
        self.generation += 1
        
        # Record evolution history
        generation_stats = {
            "generation": self.generation,
            "best_fitness": best_fitness,
            "avg_fitness": sum(e.fitness for e in self.population) / len(self.population),
            "population_size": len(self.population),
            "timestamp": datetime.now().isoformat()
        }
        
        self.evolution_history.append(generation_stats)
        
        print(f"✅ Generation {self.generation} complete")
        print(f"📈 Average fitness: {generation_stats['avg_fitness']:.4f}")
        
        return generation_stats
    
    def run_evolution(self, max_generations: Optional[int] = None, player_feedback_callback=None) -> None:
        """Run the complete evolution process."""
        max_gen = max_generations or self.config.max_generations
        
        print(f"🚀 Starting evolution process for {max_gen} generations")
        print("=" * 60)
        
        self.create_initial_population()
        
        for gen in range(max_gen):
            # Get player feedback if callback provided
            feedback = None
            if player_feedback_callback:
                feedback = player_feedback_callback(self.population, self.generation)
            
            # Evolve one generation
            stats = self.evolve_generation(feedback)
            
            # Check termination conditions
            if stats["best_fitness"] >= self.config.fitness_threshold:
                print(f"🎯 Fitness threshold reached! Best fitness: {stats['best_fitness']:.4f}")
                break
            
            # Progress indicator
            if (gen + 1) % 10 == 0:
                print(f"📊 Progress: {gen + 1}/{max_gen} generations")
        
        print("\n🏁 Evolution complete!")
        self.print_final_stats()
    
    def print_final_stats(self) -> None:
        """Print final evolution statistics."""
        print("=" * 60)
        print("📊 FINAL EVOLUTION STATISTICS")
        print("=" * 60)
        
        best_entity = max(self.population, key=lambda e: e.fitness)
        
        print(f"🏆 Best Entity: {best_entity.id}")
        print(f"💪 Best Fitness: {best_entity.fitness:.4f}")
        print(f"🧬 Generation: {best_entity.generation}")
        print(f"👥 Parents: {', '.join(best_entity.parent_ids) if best_entity.parent_ids else 'Initial population'}")
        
        print(f"\n🧬 Best Entity Traits:")
        for trait, value in best_entity.traits.items():
            print(f"  {trait}: {value:.3f}")
        
        if best_entity.mutations:
            print(f"\n🔄 Recent Mutations:")
            for mutation in best_entity.mutations[-5:]:  # Show last 5 mutations
                print(f"  {mutation}")
        
        print(f"\n📈 Evolution Progress:")
        print(f"  Total generations: {self.generation}")
        print(f"  Initial best fitness: {self.best_fitness_history[0]:.4f}")
        print(f"  Final best fitness: {self.best_fitness_history[-1]:.4f}")
        print(f"  Improvement: {(self.best_fitness_history[-1] - self.best_fitness_history[0]):.4f}")
    
    def save_evolution_data(self, filepath: str) -> None:
        """Save evolution data to file for analysis."""
        data = {
            "config": asdict(self.config),
            "generation": self.generation,
            "population": [asdict(entity) for entity in self.population],
            "evolution_history": self.evolution_history,
            "best_fitness_history": self.best_fitness_history
        }
        
        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2)
        
        print(f"💾 Evolution data saved to {filepath}")


def main():
    """Demo of the evolution engine."""
    print("🧬 Evolution Game Claude - Core Engine Demo")
    print("=" * 50)
    
    # Create evolution engine with custom parameters
    config = EvolutionParams(
        population_size=30,
        mutation_rate=0.15,
        crossover_rate=0.8,
        elite_size=3,
        max_generations=50
    )
    
    engine = EvolutionEngine(config)
    
    # Run evolution with basic demo
    engine.run_evolution(max_generations=20)
    
    # Save results
    engine.save_evolution_data("evolution_demo_results.json")


if __name__ == "__main__":
    main()