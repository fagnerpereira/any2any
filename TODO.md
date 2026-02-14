# TODO: Refactor any2any split gems

The current split into 12 specific gems (erb2slim, slim2erb, etc.) has introduced significant code duplication. Each gem currently contains its own copy of:
- IR (Intermediate Representation) nodes
- Transformers (Normalizer, Optimizer, Validator)
- Base Parser and Base Generator classes
- Error definitions and Versioning

## Recommended Refactoring
To improve maintainability and follow DRY (Don't Repeat Yourself) principles:

1. **Create `any2any-core` gem**:
   - Move all shared code (IR, Transformers, Base classes, Errors) into this core gem.
   - Each specific gem should then depend on `any2any-core`.

2. **Group by format (optional)**:
   - Instead of 12 pairs, we could have 4 format gems (`any2any-erb`, `any2any-slim`, etc.) that each contain their respective Parser and Generator.
   - The specific pair gems (`erb2slim`) could then be "glue" gems that just depend on the two format gems they need.

3. **Unified Testing**:
   - Set up a shared testing suite that can be run across all gems to ensure consistency.

## Maintenance Notes
- When fixing a bug in the IR or Transformers, currently you must apply the fix to all 12 gems.
- When adding a new format, you would need to create N*2 new gems to maintain the "every pair" structure.
