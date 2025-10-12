import os
import glob

# Find all dart files in features directory
dart_files = glob.glob('lib/features/**/*.dart', recursive=True)

print(f"Found {len(dart_files)} Dart files to update...")

for file_path in dart_files:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        # Check if import already exists
        has_apptheme_import = any('app_theme_helpers.dart' in line for line in lines)

        if has_apptheme_import:
            print(f"[SKIP] Already has import: {file_path}")
            continue

        # Find the position after other imports
        import_end_idx = 0
        for i, line in enumerate(lines):
            if line.startswith('import '):
                import_end_idx = i + 1

        # Insert the new import after existing imports
        if import_end_idx > 0:
            # Determine the correct relative path based on directory depth
            depth = file_path.count(os.sep) - 2  # lib/features/xxx/file.dart = depth 3, need ../..
            relative_path = '../' * (depth - 1)
            new_import = f"import '{relative_path}shared/util/app_theme_helpers.dart';\n"

            lines.insert(import_end_idx, new_import)

            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(lines)
            print(f"[OK] Added import: {file_path}")
        else:
            print(f"[WARN] No imports found in: {file_path}")

    except Exception as e:
        print(f"[ERROR] Error processing {file_path}: {e}")

print("\n[DONE] All imports added!")
