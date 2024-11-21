   #import "MobilityPlugin.h"
   #if __has_include(<mobility_plugin/mobility_plugin-Swift.h>)
   #import <mobility_plugin/mobility_plugin-Swift.h>
   #else
   #import "mobility_plugin-Swift.h"
   #endif

   @implementation MobilityPlugin
   + (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
       [SwiftMobilityPlugin registerWithRegistrar:registrar];
   }
   @end