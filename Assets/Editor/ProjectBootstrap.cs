#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using Kamilunavo.RepairEmpire;

namespace Kamilunavo.RepairEmpire.Editor
{
    [InitializeOnLoad]
    public static class ProjectBootstrap
    {
        private const string ScenePath = "Assets/Scenes/Main.unity";

        static ProjectBootstrap() => EditorApplication.delayCall += InitializeProject;

        public static void InitializeProject()
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode) return;

            PlayerSettings.companyName = "Kamilunavo";
            PlayerSettings.productName = "Repair Empire";
            PlayerSettings.defaultInterfaceOrientation = UIOrientation.AutoRotation;
            PlayerSettings.allowedAutorotateToPortrait=true;PlayerSettings.allowedAutorotateToLandscapeLeft=true;PlayerSettings.allowedAutorotateToLandscapeRight=true;PlayerSettings.allowedAutorotateToPortraitUpsideDown=false;PlayerSettings.iOS.targetOSVersionString="15.0";PlayerSettings.Android.minSdkVersion=AndroidSdkVersions.AndroidApiLevel26;PlayerSettings.Android.targetArchitectures=AndroidArchitecture.ARM64;PlayerSettings.SetScriptingBackend(UnityEditor.Build.NamedBuildTarget.Android,ScriptingImplementation.IL2CPP);
            PlayerSettings.bundleVersion = "1.0";
            PlayerSettings.iOS.buildNumber = "1";
            PlayerSettings.Android.bundleVersionCode = 1;
            PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.iOS, "com.kamilunavo.repairempire");
            PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, "com.kamilunavo.repairempire");

            if (!File.Exists(ScenePath))
            {
                Directory.CreateDirectory("Assets/Scenes");
                var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
                new GameObject("GameBootstrap").AddComponent<GameBootstrap>();
                EditorSceneManager.SaveScene(scene, ScenePath);
            }

            EditorBuildSettings.scenes = new[] { new EditorBuildSettingsScene(ScenePath, true) };
        }
    }
}

#endif
