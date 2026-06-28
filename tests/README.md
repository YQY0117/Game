# Test Infrastructure

**Engine**: Godot 4.6
**Test Framework**: GdUnit4
**CI**: `.github/workflows/tests.yml`
**Setup date**: 2026-06-27

## Directory Layout

```
tests/
  unit/           # Isolated unit tests (formulas, state machines, logic)
  integration/    # Cross-system and save/load tests
  smoke/          # Critical path test list for /smoke-check gate
  evidence/       # Screenshot logs and manual test sign-off records
```

## Running Tests

### Prerequisites

1. Install GdUnit4 via AssetLib:
   - Open Godot → AssetLib → search "GdUnit4" → Download & Install
   - Enable: Project → Project Settings → Plugins → GdUnit4 ✓
   - Restart editor
   - Verify: `res://addons/gdunit4/` exists

### Run from Editor

- GdUnit4 Inspector panel → Run All Tests
- Or right-click a test file → Run Tests

### Run Headless (CI)

```bash
godot --headless --script tests/gdunit4_runner.gd
```

## Test Naming

- **Files**: `[system]_[feature]_test.gd`
- **Functions**: `test_[scenario]_[expected]`
- **Example**: `damage_health_test.gd` → `test_fire_vs_ice_returns_1_5x_multiplier()`

## Story Type → Test Evidence

| Story Type | Required Evidence | Location |
|---|---|---|
| Logic | Automated unit test — must pass | `tests/unit/[system]/` |
| Integration | Integration test OR playtest doc | `tests/integration/[system]/` |
| Visual/Feel | Screenshot + lead sign-off | `tests/evidence/` |
| UI | Manual walkthrough OR interaction test | `tests/evidence/` |
| Config/Data | Smoke check pass | `production/qa/smoke-*.md` |

## CI

Tests run automatically on every push to `main` and on every pull request.
A failed test suite blocks merging.
