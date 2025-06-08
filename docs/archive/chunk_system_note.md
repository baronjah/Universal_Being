# Chunk Universal Being Base Class

The `AkashicChunk3D` extends `ChunkUniversalBeing` which should be defined in the chunks system. 

If you get an error about ChunkUniversalBeing not found, you can either:

1. Change line 1 of `akashic_chunk_3d.gd` from:
   ```gdscript
   extends ChunkUniversalBeing
   ```
   to:
   ```gdscript
   extends UniversalBeing
   ```

2. Or use the existing ChunkUniversalBeing if it's already in your project

The system will work either way since AkashicChunk3D implements all needed functionality.
