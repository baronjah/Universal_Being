#!/usr/bin/env python3
"""
Akashic Records Database Server
Connects Godot games to universal word/entity database
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import sqlite3
import json
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)  # Enable cross-origin requests from Godot

# Database setup
DB_PATH = 'akashic_records.db'

def init_database():
    """Initialize the Akashic Records database"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    # Words/Entities table
    c.execute('''CREATE TABLE IF NOT EXISTS entities
                 (id TEXT PRIMARY KEY,
                  name TEXT NOT NULL,
                  type TEXT NOT NULL,
                  evolution_stage INTEGER DEFAULT 0,
                  dimension INTEGER DEFAULT 3,
                  color TEXT,
                  connections TEXT,
                  history TEXT,
                  created_at TIMESTAMP,
                  updated_at TIMESTAMP)''')
    
    # Evolution history table
    c.execute('''CREATE TABLE IF NOT EXISTS evolution_history
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  entity_id TEXT,
                  from_stage INTEGER,
                  to_stage INTEGER,
                  dimension INTEGER,
                  timestamp TIMESTAMP,
                  FOREIGN KEY(entity_id) REFERENCES entities(id))''')
    
    # Dimensional data table
    c.execute('''CREATE TABLE IF NOT EXISTS dimensional_data
                 (dimension INTEGER PRIMARY KEY,
                  name TEXT,
                  color TEXT,
                  frequency REAL,
                  properties TEXT)''')
    
    # Insert default dimensional data
    dimensions = [
        (1, "Foundation", "AZURE", 100.0, '{"type": "basic"}'),
        (2, "Growth", "EMERALD", 200.0, '{"type": "expansion"}'),
        (3, "Energy", "AMBER", 300.0, '{"type": "power"}'),
        (4, "Insight", "VIOLET", 400.0, '{"type": "perception"}'),
        (5, "Force", "CRIMSON", 500.0, '{"type": "will"}'),
        (6, "Vision", "INDIGO", 600.0, '{"type": "foresight"}'),
        (7, "Wisdom", "SAPPHIRE", 700.0, '{"type": "understanding"}'),
        (8, "Transcendence", "GOLD", 800.0, '{"type": "ascension"}'),
        (9, "Unity", "SILVER", 900.0, '{"type": "oneness"}')
    ]
    
    for dim in dimensions:
        c.execute("INSERT OR IGNORE INTO dimensional_data VALUES (?, ?, ?, ?, ?)", dim)
    
    conn.commit()
    conn.close()

# API Routes

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'Akashic Records Database',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/entities', methods=['GET', 'POST'])
def entities():
    """Get all entities or create new one"""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    
    if request.method == 'GET':
        # Optional filters
        entity_type = request.args.get('type')
        dimension = request.args.get('dimension')
        
        query = "SELECT * FROM entities WHERE 1=1"
        params = []
        
        if entity_type:
            query += " AND type = ?"
            params.append(entity_type)
        if dimension:
            query += " AND dimension = ?"
            params.append(int(dimension))
            
        c.execute(query, params)
        entities = [dict(row) for row in c.fetchall()]
        
        # Parse JSON fields
        for entity in entities:
            entity['connections'] = json.loads(entity['connections'] or '[]')
            entity['history'] = json.loads(entity['history'] or '[]')
        
        conn.close()
        return jsonify(entities)
    
    elif request.method == 'POST':
        # Create new entity
        data = request.json
        entity_id = data.get('id', f"entity_{datetime.now().timestamp()}")
        
        c.execute("""INSERT INTO entities 
                     (id, name, type, evolution_stage, dimension, color, 
                      connections, history, created_at, updated_at)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                  (entity_id,
                   data['name'],
                   data.get('type', 'WORD'),
                   data.get('evolution_stage', 0),
                   data.get('dimension', 3),
                   data.get('color', 'CYAN'),
                   json.dumps(data.get('connections', [])),
                   json.dumps(data.get('history', [])),
                   datetime.now(),
                   datetime.now()))
        
        conn.commit()
        conn.close()
        
        return jsonify({
            'id': entity_id,
            'message': 'Entity created successfully'
        }), 201

@app.route('/entities/<entity_id>')
def get_entity(entity_id):
    """Get specific entity by ID"""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    
    c.execute("SELECT * FROM entities WHERE id = ?", (entity_id,))
    row = c.fetchone()
    
    if not row:
        conn.close()
        return jsonify({'error': 'Entity not found'}), 404
    
    entity = dict(row)
    entity['connections'] = json.loads(entity['connections'] or '[]')
    entity['history'] = json.loads(entity['history'] or '[]')
    
    conn.close()
    return jsonify(entity)

@app.route('/entities/<entity_id>/evolve', methods=['POST'])
def evolve_entity(entity_id):
    """Evolve entity to new stage"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    data = request.json
    new_stage = data['stage']
    
    # Get current entity
    c.execute("SELECT evolution_stage, dimension FROM entities WHERE id = ?", (entity_id,))
    result = c.fetchone()
    
    if not result:
        conn.close()
        return jsonify({'error': 'Entity not found'}), 404
    
    old_stage, dimension = result
    
    # Update entity
    c.execute("""UPDATE entities 
                 SET evolution_stage = ?, updated_at = ? 
                 WHERE id = ?""",
              (new_stage, datetime.now(), entity_id))
    
    # Record evolution history
    c.execute("""INSERT INTO evolution_history 
                 (entity_id, from_stage, to_stage, dimension, timestamp)
                 VALUES (?, ?, ?, ?, ?)""",
              (entity_id, old_stage, new_stage, dimension, datetime.now()))
    
    conn.commit()
    conn.close()
    
    return jsonify({
        'success': True,
        'entity_id': entity_id,
        'new_stage': new_stage
    })

@app.route('/entities/<entity_id>/connect', methods=['POST'])
def connect_entities(entity_id):
    """Connect two entities"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    data = request.json
    target_id = data['target_id']
    
    # Get current connections
    c.execute("SELECT connections FROM entities WHERE id = ?", (entity_id,))
    result = c.fetchone()
    
    if not result:
        conn.close()
        return jsonify({'error': 'Entity not found'}), 404
    
    connections = json.loads(result[0] or '[]')
    
    if target_id not in connections:
        connections.append(target_id)
        
        # Update both entities
        c.execute("UPDATE entities SET connections = ? WHERE id = ?",
                  (json.dumps(connections), entity_id))
        
        # Add reverse connection
        c.execute("SELECT connections FROM entities WHERE id = ?", (target_id,))
        target_result = c.fetchone()
        if target_result:
            target_connections = json.loads(target_result[0] or '[]')
            if entity_id not in target_connections:
                target_connections.append(entity_id)
                c.execute("UPDATE entities SET connections = ? WHERE id = ?",
                          (json.dumps(target_connections), target_id))
    
    conn.commit()
    conn.close()
    
    return jsonify({
        'success': True,
        'connected': [entity_id, target_id]
    })

@app.route('/dimensions')
def get_dimensions():
    """Get all dimensional data"""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    
    c.execute("SELECT * FROM dimensional_data")
    dimensions = [dict(row) for row in c.fetchall()]
    
    for dim in dimensions:
        dim['properties'] = json.loads(dim['properties'])
    
    conn.close()
    return jsonify(dimensions)

@app.route('/search', methods=['POST'])
def search_entities():
    """Advanced search for entities"""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    
    data = request.json
    query_parts = []
    params = []
    
    if 'name_contains' in data:
        query_parts.append("name LIKE ?")
        params.append(f"%{data['name_contains']}%")
    
    if 'min_evolution' in data:
        query_parts.append("evolution_stage >= ?")
        params.append(data['min_evolution'])
    
    if 'dimensions' in data:
        placeholders = ','.join('?' * len(data['dimensions']))
        query_parts.append(f"dimension IN ({placeholders})")
        params.extend(data['dimensions'])
    
    where_clause = " AND ".join(query_parts) if query_parts else "1=1"
    query = f"SELECT * FROM entities WHERE {where_clause}"
    
    c.execute(query, params)
    entities = [dict(row) for row in c.fetchall()]
    
    for entity in entities:
        entity['connections'] = json.loads(entity['connections'] or '[]')
        entity['history'] = json.loads(entity['history'] or '[]')
    
    conn.close()
    return jsonify(entities)

# Godot Integration Example
@app.route('/godot/sync', methods=['POST'])
def godot_sync():
    """Sync batch of entities from Godot"""
    data = request.json
    entities = data.get('entities', [])
    
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    synced = []
    for entity in entities:
        # Upsert logic
        c.execute("""INSERT OR REPLACE INTO entities 
                     (id, name, type, evolution_stage, dimension, color, 
                      connections, history, created_at, updated_at)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, 
                             COALESCE((SELECT created_at FROM entities WHERE id = ?), ?),
                             ?)""",
                  (entity['id'],
                   entity['name'],
                   entity.get('type', 'WORD'),
                   entity.get('evolution_stage', 0),
                   entity.get('dimension', 3),
                   entity.get('color', 'CYAN'),
                   json.dumps(entity.get('connections', [])),
                   json.dumps(entity.get('history', [])),
                   entity['id'],
                   datetime.now(),
                   datetime.now()))
        synced.append(entity['id'])
    
    conn.commit()
    conn.close()
    
    return jsonify({
        'synced': len(synced),
        'entity_ids': synced
    })

if __name__ == '__main__':
    # Initialize database on first run
    if not os.path.exists(DB_PATH):
        print("Initializing Akashic Records database...")
        init_database()
        print("Database initialized!")
    
    print("Starting Akashic Records server on http://localhost:7777")
    print("Connect from Godot using HTTPRequest to this address")
    
    app.run(debug=True, host='0.0.0.0', port=7777)