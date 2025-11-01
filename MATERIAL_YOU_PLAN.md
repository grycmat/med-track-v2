# Material You (Dynamic Theming) Implementation Plan

## Overview
Implement Material You dynamic color system on Android (API 31+) while maintaining fallback themes for older devices and full iOS compatibility.

## Current State Analysis

**Existing Theme System**:
- Custom `AppTheme` with hardcoded light/dark color schemes
- `AppColors` with static color palette (purple-based primary)
- Manual theme mode selection (system, light, dark)
- Theme persistence in UserPreferences table
- No dynamic color extraction

**Target State**:
- Detect and extract system colors on Android 12+ (Material You)
- Generate harmonized color schemes using Material Color Utilities
- Fallback to current hardcoded palette on Android <12 and iOS
- Preserve all existing functionality
- Seamless theme transitions

## Implementation Strategy

### Phase 1: Add Dependencies & Setup
**Objective**: Prepare project for dynamic color support

**Tasks**:
1. Add `material_color_utilities` package to pubspec.yaml (Material Design 3 color system)
2. Add `dynamic_color` package (handles Material You extraction on Android 12+)
3. Create `.dart_tool/` gitignore if needed for generated files
4. Update `analysis_options.yaml` if needed for new dependencies

**Files to Modify**:
- `pubspec.yaml` - Add dependencies

**New Files**: None

**Expected Output**: Project compiles with new packages available

---

### Phase 2: Create Dynamic Color Service Layer
**Objective**: Abstract color extraction logic with fallback strategy

**Tasks**:
1. Create `lib/services/dynamic_color_service.dart`
   - Interface for color extraction
   - `extractPrimaryColor()` → Future<Color?> 
   - `extractSecondaryColor()` → Future<Color?>
   - `isMaterialYouAvailable()` → Future<bool> (check API level + package capability)
   - Handle platform exceptions gracefully

2. Create `lib/models/dynamic_theme_colors.dart`
   - Data class holding extracted colors
   - Fields: primary, secondary, tertiary, error, etc.
   - `isDynamic` flag to track if from Material You or fallback
   - Factory constructors for fallback scenarios

**Files to Modify**: None

**New Files**:
- `lib/services/dynamic_color_service.dart`
- `lib/models/dynamic_theme_colors.dart`

**Expected Output**: Reusable service for color extraction with fallback

---

### Phase 3: Refactor Theme System
**Objective**: Make `AppTheme` dynamic while preserving existing behavior

**Tasks**:
1. Modify `lib/theme/app_theme.dart`
   - Add static method: `createDynamicLightTheme(Color primaryColor) → ThemeData`
   - Add static method: `createDynamicDarkTheme(Color primaryColor) → ThemeData`
   - Extract current hardcoded colors into `_createColorScheme()` helper
   - Keep existing `lightTheme` and `darkTheme` as fallbacks
   - Use ColorScheme.fromSeed() for tonal palette generation (Material 3)

2. Modify `lib/theme/app_colors.dart`
   - Add static method: `getFallbackPalette()` returning current colors as reference
   - Mark existing constants as `@deprecated` (with comment to use dynamic theming)
   - Keep constants for semantic colors (success, warning, error, info) unchanged

**Files to Modify**:
- `lib/theme/app_theme.dart`
- `lib/theme/app_colors.dart`

**New Files**: None

**Expected Output**: AppTheme supports dynamic color generation

---

### Phase 4: Integrate Dynamic Theming into Main App
**Objective**: Initialize dynamic colors on app startup and sync with storage

**Tasks**:
1. Update `lib/main.dart`
   - In `main()`: Call `WidgetsFlutterBinding.ensureInitialized()` first (already done)
   - Create `DynamicColorService` instance before `MedTrackV2App`
   - Provide `DynamicColorService` via Provider
   
2. Modify `_AppWrapperState` in main.dart
   - Add field: `Color? _extractedPrimaryColor`
   - In `initState()`: Load stored dynamic color preference
   - In `_checkOnboardingStatus()`: After loading theme mode, call `_initializeDynamicColors()`
   - New method: `_initializeDynamicColors()` 
     - Check if Material You available
     - Extract primary color
     - Store preference (optional: allow user to toggle)
   - Pass extracted color to `AppTheme` static methods

3. Create new state for dynamic color preference storage
   - Add column in `UserPreferences` table: `useDynamicColors` (bool, default true)
   - Update `UserPreferencesService` with getters/setters
   - Allow user to disable Material You in settings

**Files to Modify**:
- `lib/main.dart`
- `lib/services/user_preferences_service.dart`
- `lib/database/tables/user_preferences_table.dart`

**New Files**: None

**Expected Output**: Dynamic colors extracted and applied on startup

---

### Phase 5: UI for Material You Toggle (Settings Screen)
**Objective**: Give users control over dynamic theming

**Tasks**:
1. Modify `lib/screens/settings/settings.screen.dart`
   - Add Material You toggle switch
   - Visible only on Android 12+ (use `isMaterialYouAvailable()`)
   - Toggle updates: `UserPreferencesService` → triggers theme refresh
   - Show "Material You theme" label with description

2. Modify `SettingsViewModel`
   - Add `useDynamicColors` state property
   - Add `toggleDynamicColors()` method
   - Call `_updateThemeMode()` parent callback after toggle to refresh theme

**Files to Modify**:
- `lib/screens/settings/settings.screen.dart`
- `lib/viewmodels/settings_viewmodel.dart`

**Expected Output**: Users can toggle Material You on/off

---

### Phase 6: Theme Refresh Mechanism
**Objective**: Allow hot theme switching without app restart

**Tasks**:
1. Create theme change callback in `_AppWrapperState`
   - New method: `_refreshThemeWithDynamicColors()`
   - Re-extract primary color
   - Call `setState()` to trigger MaterialApp rebuild

2. Wire settings screen to theme refresh
   - Settings → Toggle Material You → Call parent callback → Refresh theme
   - Use callback pattern via widget parameter or Provider

**Files to Modify**:
- `lib/main.dart`
- `lib/screens/settings/settings.screen.dart`

**Expected Output**: Theme updates in real-time when toggled

---

### Phase 7: Database Schema Migration
**Objective**: Add dynamic color preference to persistent storage

**Tasks**:
1. Update `lib/database/tables/user_preferences_table.dart`
   - Add column: `useDynamicColors` TextColumn (default: 'true')
   - Rationale: Store as string for consistency with other preferences

2. Update `lib/database/app_database.dart`
   - Increment `schemaVersion` to 3
   - Add migration in `onUpgrade()` to add column with default value

3. Run `dart run build_runner build` to regenerate database code

4. Update `UserPreferencesService`
   - Add: `getDynamicColorPreference() → Future<bool>`
   - Add: `saveDynamicColorPreference(bool) → Future<void>`

**Files to Modify**:
- `lib/database/tables/user_preferences_table.dart`
- `lib/database/app_database.dart`
- `lib/services/user_preferences_service.dart`

**Expected Output**: Database can persist user preference

---

## Implementation Order (Sequential)

1. ✅ Phase 1: Dependencies
2. ✅ Phase 2: Dynamic Color Service
3. ✅ Phase 3: Refactor AppTheme
4. ✅ Phase 4: Integrate into main.dart
5. ✅ Phase 5: Settings UI
6. ✅ Phase 6: Theme refresh
7. ✅ Phase 7: Database persistence

## Fallback Strategy

| Scenario | Behavior |
|----------|----------|
| Android 12+ with Material You | Extract system accent color, generate tonal palette |
| Android <12 | Use hardcoded AppColors palette |
| iOS | Use hardcoded AppColors palette |
| User disables Material You | Use hardcoded AppColors palette |
| Color extraction fails | Fallback to hardcoded palette + log error |

## API Level Considerations

- **Target**: Material You available on Android 12+ (API 31)
- **Project minSdkVersion**: Check `android/app/build.gradle.kts`
- **Fallback**: Must work on all API levels the project supports
- **Runtime check**: Use `dynamic_color` package or platform channels to verify Material You availability

## WARP.md Updates Needed

After implementation, update WARP.md:
- Add Material You initialization to "Essential Commands"
- Document `DynamicColorService` in architecture section
- Add "Dynamic Theming" section with usage patterns
- Update database schema version to 3
- Add troubleshooting section for color extraction

## Testing Checklist

- [ ] Light theme with dynamic colors (Android 12+ device)
- [ ] Dark theme with dynamic colors (Android 12+ device)
- [ ] Fallback theme on Android <12
- [ ] Toggle Material You on/off without restart
- [ ] Settings screen shows Material You option (Android 12+ only)
- [ ] iOS uses fallback palette (no Material You access)
- [ ] Theme persists after app restart
- [ ] Color preference persists after app restart
- [ ] Error handling: extraction fails gracefully
- [ ] Multiple rapid toggles don't crash app

## Estimated Effort

- Phase 1: 15 min (dependencies)
- Phase 2: 45 min (service layer)
- Phase 3: 30 min (theme refactoring)
- Phase 4: 60 min (main integration + database)
- Phase 5: 30 min (settings UI)
- Phase 6: 20 min (refresh mechanism)
- Phase 7: 30 min (database migration)

**Total**: ~3.5 hours

## Risk Assessment

**Low Risk**:
- Phase 1-3: Additive changes, existing theme remains unchanged
- Phase 7: Database migration (similar to previous schema upgrade)

**Medium Risk**:
- Phase 4-5: Affects app initialization flow
- Mitigation: Keep fallback themes as safety net

**Mitigation Strategies**:
- Fully backward compatible (existing users unaffected)
- Feature flag: `useDynamicColors` allows easy disable
- Comprehensive error handling in color extraction
- Existing hardcoded themes always available

## Questions for Review

1. Should Material You be enabled by default on Android 12+?
2. Should iOS ever support dynamic theming (via wallpaper analysis) in future?
3. Any constraints on minimum Android API version?
4. Preference: Store `useDynamicColors` as bool or String in database?
5. Should accent color extraction prioritize primary or use full palette?
