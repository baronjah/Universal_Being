::: mermaid
graph TD;
    Main[Main System] --> Camera[Camera System];
    Main --> Core[Core Systems];
    Main --> Interface[Interface Elements];
    Main --> Records[Records System];
    Main --> Threading[Threading System];

    Camera --> |Scripts| CM[camera_move.gd<br/>camera_mover.gd];
    Camera --> |Nodes| CN[TrackballCamera<br/>CameraMover];

    Core --> TC[Time Control];
    Core --> SC[System Check];
    Core --> Tree[Tree Management];
    
    TC --> |Scripts| TS[godot_timers_system.gd];
    SC --> |Scripts| SCS[system_check.gd<br/>system_interfaces.gd];
    Tree --> |Scripts| TRS[tree_blueprints_bank.gd<br/>scene_tree_check.gd];

    Interface --> |Scripts| UI[button.gd<br/>cursor_pc.gd<br/>line.gd];

    Records --> DataMgmt[Data Management];
    Records --> Cache[Cache System];
    Records --> Storage[Storage System];

    DataMgmt --> |Scripts| DM[banks_combiner.gd<br/>record_set_manager.gd];
    Cache --> |Scripts| CS[JSH_cache_memory_system];
    Storage --> |Scripts| SS[records_bank.gd<br/>scenes_bank.gd];

    Threading --> TaskMgmt[Task Management];
    Threading --> Queue[Queue System];
    
    TaskMgmt --> |Scripts| TM[thread_pool_manager.gd<br/>jsh_task_manager.gd];
    Queue --> |Scripts| QS[JSH_queue_system<br/>JSH_turns_system];
:::