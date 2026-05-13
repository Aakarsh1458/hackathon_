/// Placeholder contracts for future immersive wellness integrations.
abstract interface class ImmersiveWellnessAdapter {
  Future<void> initialize();
  Future<void> openCalmingSpace({
    required double stressLevel,
    required double wellnessScore,
  });
}

class NoopImmersiveWellnessAdapter implements ImmersiveWellnessAdapter {
  const NoopImmersiveWellnessAdapter();

  @override
  Future<void> initialize() async {
    // TODO(ar-vr): Replace with AR/VR runtime integration.
  }

  @override
  Future<void> openCalmingSpace({
    required double stressLevel,
    required double wellnessScore,
  }) async {
    // TODO(ar-vr): Open immersive wellness scene with adaptive ambiance.
  }
}
