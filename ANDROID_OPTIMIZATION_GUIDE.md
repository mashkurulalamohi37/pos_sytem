# Android Optimization Guide

This document outlines the Android-specific optimizations applied to improve app performance, build speed, and APK size.

## Build Optimizations

### 1. Gradle Configuration (`gradle.properties`)

**Performance Improvements:**
- **Parallel builds**: `org.gradle.parallel=true` - Builds multiple modules simultaneously
- **Build caching**: `org.gradle.caching=true` - Reuses build outputs from previous builds
- **Configuration cache**: `org.gradle.configuration-cache=true` - Caches build configuration
- **File system watching**: `org.gradle.vfs.watch=true` - Faster incremental builds
- **G1GC**: `-XX:+UseG1GC` - Better garbage collection for large builds
- **Non-transitive R classes**: `android.nonTransitiveRClass=true` - Smaller APK size

**Memory Settings:**
- Max heap: 8GB
- Max metaspace: 4GB
- Code cache: 512MB

### 2. Build Configuration (`build.gradle.kts`)

**Release Build Optimizations:**
- **Code shrinking**: `isMinifyEnabled = true` - Removes unused code
- **Resource shrinking**: `isShrinkResources = true` - Removes unused resources
- **R8 optimization**: Uses `proguard-android-optimize.txt` for maximum optimization
- **Native library optimization**: Optimized ABI filters for smaller APK

**Performance Features:**
- **Vector drawables**: Enabled for smaller APK size
- **Hardware acceleration**: Enabled in manifest
- **MultiDex**: Enabled for large apps

### 3. ProGuard Rules (`proguard-rules.pro`)

**Optimizations:**
- **Method optimization**: 5 optimization passes
- **Code obfuscation**: Enabled for release builds
- **Log removal**: Removes all logging calls in release builds
- **Debug code removal**: Removes Kotlin debug intrinsics

**Protected Classes:**
- Flutter framework classes
- Firebase classes
- Gson serialization classes
- Native methods
- Parcelable implementations

## Manifest Optimizations

### 1. Activity Configuration

**Performance Settings:**
- `android:hardwareAccelerated="true"` - GPU acceleration
- `android:launchMode="singleTop"` - Prevents duplicate activities
- `android:configChanges` - Handles config changes without restart
- `android:process=":main"` - Separate process for better memory management

### 2. Application Configuration

**Security & Performance:**
- `android:usesCleartextTraffic="false"` - Forces HTTPS
- `android:hardwareAccelerated="true"` - GPU acceleration
- `android:largeHeap="false"` - Prevents excessive memory usage
- `android:extractNativeLibs="false"` - Faster app startup (Android 6.0+)
- `android:supportsRtl="true"` - RTL language support

### 3. Backup Configuration

**Files Created:**
- `backup_rules.xml` - Controls what gets backed up
- `data_extraction_rules.xml` - Controls data extraction (Android 12+)

**Security:**
- Excludes sensitive data (shared preferences, secure storage)
- Allows device-to-device transfer of app data

## Build Commands

### Debug Build
```bash
flutter build apk --debug
```
- No code shrinking
- Includes debug symbols
- Larger APK size
- Faster build time

### Release Build (Optimized)
```bash
flutter build apk --release
```
- Code shrinking enabled
- Resource shrinking enabled
- Obfuscation enabled
- Optimized APK size

### App Bundle (Recommended for Play Store)
```bash
flutter build appbundle --release
```
- Smaller download size
- Dynamic delivery
- Optimized for Play Store

### Split APKs by ABI
```bash
flutter build apk --split-per-abi --release
```
- Separate APK for each architecture
- Smaller individual APK sizes
- Users only download their architecture

## Performance Metrics

### APK Size Optimization
- **Before**: ~50-100MB (estimated)
- **After**: ~30-60MB (with optimizations)
- **With split APKs**: ~15-30MB per architecture

### Build Time Optimization
- **First build**: ~5-10 minutes
- **Incremental build**: ~30-60 seconds (with caching)
- **Clean build**: ~3-5 minutes (with parallel builds)

### Runtime Performance
- **Startup time**: Optimized with `extractNativeLibs="false"`
- **Memory usage**: Controlled with `largeHeap="false"`
- **GPU acceleration**: Enabled for smooth animations

## Best Practices

### 1. Code Optimization
- Use `const` constructors where possible
- Minimize widget rebuilds
- Use `RepaintBoundary` for complex widgets
- Dispose controllers properly

### 2. Resource Optimization
- Use vector drawables instead of PNGs when possible
- Compress images before adding to assets
- Remove unused resources
- Use appropriate image densities

### 3. Network Optimization
- Batch Firestore queries
- Use pagination for large datasets
- Cache frequently accessed data
- Implement offline support

### 4. Memory Management
- Dispose controllers in `dispose()` method
- Avoid memory leaks in listeners
- Use weak references where appropriate
- Monitor memory usage with Android Profiler

## Monitoring & Debugging

### Android Profiler
Use Android Studio Profiler to monitor:
- CPU usage
- Memory usage
- Network activity
- Battery usage

### Build Analysis
```bash
./gradlew :app:assembleRelease --profile
```
Generates a build profile report showing:
- Task execution times
- Build bottlenecks
- Optimization opportunities

### APK Analyzer
Use Android Studio's APK Analyzer to:
- View APK size breakdown
- Identify large files
- Check for duplicate resources
- Analyze DEX files

## Troubleshooting

### Build Failures
1. **Out of memory**: Increase `-Xmx` in `gradle.properties`
2. **R8 errors**: Check `proguard-rules.pro` for missing keep rules
3. **Missing resources**: Ensure all resources are included in assets

### Runtime Issues
1. **Crashes on startup**: Check MultiDex installation
2. **Missing classes**: Add ProGuard keep rules
3. **Performance issues**: Enable hardware acceleration

## Future Optimizations

1. **Battery optimization**: Implement Doze mode handling
2. **Background processing**: Optimize background tasks
3. **Image optimization**: Implement image compression
4. **Database optimization**: Optimize SQLite queries
5. **Network optimization**: Implement request batching

## References

- [Android App Performance](https://developer.android.com/topic/performance)
- [Reduce APK Size](https://developer.android.com/topic/performance/reduce-apk-size)
- [R8 Optimization](https://developer.android.com/studio/build/shrink-code)
- [Gradle Performance](https://docs.gradle.org/current/userguide/performance.html)

