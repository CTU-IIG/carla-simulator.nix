```
ERROR: Unhandled exception: System.Reflection.TargetInvocationException: Exception has been thrown by the target of an invocation. ---> System.Security.SecurityException: No access to the given key ---> System.UnauthorizedAccessException: Access to the path '/nix/store/4wwb5ffx84m0knzdba88gdj1nklkq794-mono-6.12.0.182/etc/mono/registry/LocalMachine' is denied. ---> System.IO.IOException: Permission denied
          --- End of inner exception stack trace ---
         at System.IO.FileSystem.CreateDirectory (System.String fullPath) [0x00191] in <77c17096f50d4e2abb928c947473b5c0>:0
         at System.IO.Directory.CreateDirectory (System.String path) [0x0002c] in <77c17096f50d4e2abb928c947473b5c0>:0
         at Microsoft.Win32.KeyHandler..ctor (Microsoft.Win32.RegistryKey rkey, System.String basedir, System.Boolean is_volatile) [0x00038] in <77c17096f50d4e2abb928c947473b5c0>:0
          --- End of inner exception stack trace ---
         at Microsoft.Win32.KeyHandler..ctor (Microsoft.Win32.RegistryKey rkey, System.String basedir, System.Boolean is_volatile) [0x0004d] in <77c17096f50d4e2abb928c947473b5c0>:0
         at Microsoft.Win32.KeyHandler..ctor (Microsoft.Win32.RegistryKey rkey, System.String basedir) [0x00000] in <77c17096f50d4e2abb928c947473b5c0>:0
         at Microsoft.Win32.KeyHandler.Lookup (Microsoft.Win32.RegistryKey rkey, System.Boolean createNonExisting) [0x000bf] in <77c17096f50d4e2abb928c947473b5c0>:0
         at Microsoft.Win32.UnixRegistryApi.OpenSubKey (Microsoft.Win32.RegistryKey rkey, System.String keyname, System.Boolean writable) [0x00000] in <77c17096f50d4e2abb928c947473b5c0>:0
         at Microsoft.Win32.RegistryKey.OpenSubKey (System.String name, System.Boolean writable) [0x0001b] in <77c17096f50d4e2abb928c947473b5c0>:0
         at Microsoft.Win32.RegistryKey.OpenSubKey (System.String name) [0x00000] in <77c17096f50d4e2abb928c947473b5c0>:0
         at (wrapper remoting-invoke-with-check) Microsoft.Win32.RegistryKey.OpenSubKey(string)
         at UnrealBuildTool.AndroidProjectGenerator..ctor (Tools.DotNETCommon.CommandLineArguments Arguments) [0x0001b] in <2e7b48086a794f59bce450298e2c4892>:0
         at (wrapper managed-to-native) System.Reflection.RuntimeConstructorInfo.InternalInvoke(System.Reflection.RuntimeConstructorInfo,object,object[],System.Exception&)
         at System.Reflection.RuntimeConstructorInfo.InternalInvoke (System.Object obj, System.Object[] parameters, System.Boolean wrapExceptions) [0x00005] in <77c17096f50d4e2abb928c947473b5c0>:0
          --- End of inner exception stack trace ---
         at System.Reflection.RuntimeConstructorInfo.InternalInvoke (System.Object obj, System.Object[] parameters, System.Boolean wrapExceptions) [0x0001a] in <77c17096f50d4e2abb928c947473b5c0>:0
         at System.Reflection.RuntimeConstructorInfo.DoInvoke (System.Object obj, System.Reflection.BindingFlags invokeAttr, System.Reflection.Binder binder, System.Object[] parameters, System.Globalization.CultureInfo culture) [0x00086] in <77c17096f50d4e2abb928c947473b5c0>:0
         at System.Reflection.RuntimeConstructorInfo.Invoke (System.Reflection.BindingFlags invokeAttr, System.Reflection.Binder binder, System.Object[] parameters, System.Globalization.CultureInfo culture) [0x00000] in <77c17096f50d4e2abb928c947473b5c0>:0
         at System.RuntimeType.CreateInstanceImpl (System.Reflection.BindingFlags bindingAttr, System.Reflection.Binder binder, System.Object[] args, System.Globalization.CultureInfo culture, System.Object[] activationAttributes, System.Threading.StackCrawlMark& stackMark) [0x0022b] in <77c17096f50d4e2abb928c947473b5c0>:0
         at System.Activator.CreateInstance (System.Type type, System.Reflection.BindingFlags bindingAttr, System.Reflection.Binder binder, System.Object[] args, System.Globalization.CultureInfo culture, System.Object[] activationAttributes) [0x0009c] in <77c17096f50d4e2abb928c947473b5c0>:0
         at System.Activator.CreateInstance (System.Type type, System.Object[] args) [0x00000] in <77c17096f50d4e2abb928c947473b5c0>:0
         at UnrealBuildTool.GenerateProjectFilesMode.Execute (Tools.DotNETCommon.CommandLineArguments Arguments) [0x001d0] in <2e7b48086a794f59bce450298e2c4892>:0
         at UnrealBuildTool.UnrealBuildTool.Main (System.String[] ArgumentsArray) [0x002bb] in <2e7b48086a794f59bce450298e2c4892>:0
```

# Clang toolchain

- Problem: Toolchain path is hardcoded to Engine/Extras/ThirdPartyNotUE/SDKs/HostLinux/Linux_x64/...
- Solution: Download the toolchain and patchelf it
- URL: http://cdn.unrealengine.com/Toolchain_Linux/native-linux/v17_clang-10.0.1-centos7.tar.gz

# UnrealHeaderTool CrashReportClient error

```
carla-ue4> [34/38] Link (lld) libUnrealHeaderTool-Json.so
carla-ue4> [35/38] Link (lld) libUnrealHeaderTool-Projects.so
carla-ue4> [36/38] Link (lld) libUnrealHeaderTool-CoreUObject.so
carla-ue4> [37/38] Link (lld) UnrealHeaderTool
carla-ue4> [38/38] UnrealBuildTool.exe UnrealHeaderTool.target
carla-ue4> Total time in Local executor: 62.61 seconds
carla-ue4> Parsing headers for CrashReportClient
carla-ue4>   Running UnrealHeaderTool CrashReportClient "/build/UnrealEngine-0.9.13/Engine/Intermediate/Build/Linux/B4D820EA/CrashReportClient/Shipping/CrashReportClient.uhtmanifest" -LogCmds="loginit warning, logexit warning, logdatabase error" -Unattended -WarningsAsErrors -abslog="/build/UnrealEngine-0.9.13/Engine/Programs/UnrealBuildTool/Log_UHT.txt"
carla-ue4> make: *** [Makefile:327: CrashReportClient-Linux-Shipping] Error 3
```

- Solution: Run `autoPatchelf Engine/Binaries/Linux` after
  `./GenerateProjectFiles.sh`.
  (not reliable?)
