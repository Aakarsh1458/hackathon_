import 'wellness_module_contract.dart';

/// Loose registry — modules register from outside the shell package boundary if needed.
///
/// TODO (composition root): Call [register] after importing each module's public facade.
/// Do not import module internals from the shell — only facades implementing [WellnessModuleContract].
class ModuleRegistrationBus {
  ModuleRegistrationBus._();

  static final ModuleRegistrationBus instance = ModuleRegistrationBus._();

  final Map<String, WellnessModuleContract> _modules = {};

  List<WellnessModuleContract> get modules => List.unmodifiable(_modules.values);

  void register(WellnessModuleContract module) {
    _modules[module.moduleId] = module;
  }

  void unregister(String moduleId) {
    _modules.remove(moduleId);
  }

  WellnessModuleContract? operator [](String moduleId) => _modules[moduleId];
}
