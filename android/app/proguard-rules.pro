# Keep BLoC/Equatable/Dartz class names — reflection-free in our case, but
# harmless to keep for stack traces in release crash reports.
-keep class com.mohammeddaghmah.flutter_clean_architecture_template.** { *; }

# Hive uses reflection-free adapters here, but keep TypeAdapters safe by
# convention in case one is added later.
-keep class * extends com.google.gson.TypeAdapter
