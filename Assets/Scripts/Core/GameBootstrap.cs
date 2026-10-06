using UnityEngine;
using UnityEngine.EventSystems;
using Kamilunavo.RepairEmpire.CameraSystem;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Input;
using Kamilunavo.RepairEmpire.UI;

namespace Kamilunavo.RepairEmpire
{
    public sealed class GameBootstrap : MonoBehaviour
    {
        private static readonly Color Navy = new(0.025f, 0.085f, 0.14f, 0.96f);
        private static readonly Color Panel = new(0.045f, 0.14f, 0.22f, 0.96f);
        private static readonly Color Orange = new(1f, 0.32f, 0.07f);
        private static readonly Color White = new(0.97f, 0.99f, 1f);

        private void Start()
        {
            Screen.orientation = ScreenOrientation.Portrait;
            Application.targetFrameRate = 60;
            QualitySettings.vSyncCount = 0;
            EnsureEventSystem();
            CreateLighting();

            var city = new GameObject("City").AddComponent<CityBuilder>();
            city.Build();

            var canvas = UiFactory.CreateCanvas();
            var safe = UiFactory.Panel(canvas.transform, "SafeArea", Color.clear, Vector2.zero, Vector2.one);
            safe.gameObject.AddComponent<SafeAreaFitter>();

            var cash = HudCard(safe, "Cash", "CASH\n$1,130", new Vector2(0.03f, 0.91f), new Vector2(0.31f, 0.98f));
            var level = HudCard(safe, "Level", "LEVEL 2\n124 / 143 XP", new Vector2(0.33f, 0.91f), new Vector2(0.61f, 0.98f));
            var tool = HudCard(safe, "Tool", "TOOL\nBasic Wrench", new Vector2(0.63f, 0.91f), new Vector2(0.90f, 0.98f));
            UiFactory.Button(safe, "Settings", "⚙", Navy, White, new Vector2(0.91f, 0.91f), new Vector2(0.98f, 0.98f), () => { });

            var mission = UiFactory.Panel(safe, "Mission", Navy, new Vector2(0.03f, 0.64f), new Vector2(0.50f, 0.88f));
            var jobTitle = UiFactory.Label(mission, "Job", "SERVICE CALL\nLeaking Faucet", 34, new Vector2(0.06f, 0.58f), new Vector2(0.94f, 0.93f), TextAnchor.MiddleLeft, White, FontStyle.Bold);
            var jobMeta = UiFactory.Label(mission, "Meta", "Riverside Apartments\n$120 • 100 XP", 27, new Vector2(0.06f, 0.26f), new Vector2(0.94f, 0.58f), TextAnchor.UpperLeft, new Color(0.72f, 0.80f, 0.88f));
            var distance = UiFactory.Label(mission, "Distance", "284 m", 34, new Vector2(0.06f, 0.10f), new Vector2(0.42f, 0.27f), TextAnchor.MiddleLeft, White, FontStyle.Bold);
            UiFactory.Button(mission, "Navigate", "NAVIGATE", Orange, White, new Vector2(0.45f, 0.07f), new Vector2(0.94f, 0.27f), () => { });

            var status = UiFactory.Label(safe, "Status", "0 KM/H", 28, new Vector2(0.35f, 0.18f), new Vector2(0.65f, 0.23f), TextAnchor.MiddleCenter, White, FontStyle.Bold);

            var left = HoldButton.Create(safe, "‹", new Vector2(0.03f, 0.04f), new Vector2(0.14f, 0.17f), Navy);
            var right = HoldButton.Create(safe, "›", new Vector2(0.15f, 0.04f), new Vector2(0.26f, 0.17f), Navy);
            var brake = HoldButton.Create(safe, "BRAKE", new Vector2(0.61f, 0.04f), new Vector2(0.76f, 0.15f), Panel);
            var accel = HoldButton.Create(safe, "GO", new Vector2(0.79f, 0.04f), new Vector2(0.97f, 0.17f), Panel);

            var van = CreateVan();
            var vehicle = van.GetComponent<VehicleController>();
            vehicle.Left = left;
            vehicle.Right = right;
            vehicle.Brake = brake;
            vehicle.Accelerate = accel;
            CreateCamera(van.transform);

            var gameObject = new GameObject("RepairGame");
            var game = gameObject.AddComponent<RepairGame>();
            game.Vehicle = vehicle;
            game.CashText = cash;
            game.LevelText = level;
            game.ToolText = tool;
            game.JobTitle = jobTitle;
            game.JobMeta = jobMeta;
            game.DistanceText = distance;
            game.StatusText = status;

            var complete = UiFactory.Button(safe, "Complete", "COMPLETE REPAIR", new Color(0.10f, 0.70f, 0.35f), White, new Vector2(0.54f, 0.56f), new Vector2(0.96f, 0.63f), game.CompleteActiveJob);
            game.CompleteButton = complete;
            complete.gameObject.SetActive(false);

            var tabletRoot = UiFactory.Panel(safe, "TabletRoot", new Color(0.01f, 0.035f, 0.06f, 0.995f), new Vector2(0.03f, 0.10f), new Vector2(0.97f, 0.90f));
            var tablet = tabletRoot.gameObject.AddComponent<TabletController>();
            tablet.Game = game;
            tablet.Vehicle = vehicle;
            tablet.Root = tabletRoot;
            tablet.Build();
            tabletRoot.gameObject.SetActive(false);

            UiFactory.Button(safe, "Tablet", "TABLET", Orange, White, new Vector2(0.79f, 0.65f), new Vector2(0.97f, 0.73f), tablet.Toggle);
        }

        private static UnityEngine.UI.Text HudCard(Transform parent, string name, string value, Vector2 min, Vector2 max)
        {
            var panel = UiFactory.Panel(parent, name, Navy, min, max);
            return UiFactory.Label(panel, "Text", value, 29, new Vector2(0.08f, 0.08f), new Vector2(0.92f, 0.92f), TextAnchor.MiddleLeft, White, FontStyle.Bold);
        }

        private static GameObject CreateVan()
        {
            var root = new GameObject("ServiceVan");
            root.transform.position = new Vector3(0f, 1.2f, 0f);

            var body = root.AddComponent<Rigidbody>();
            body.mass = 1450f;
            body.linearDamping = 0.25f;
            body.angularDamping = 2.5f;
            body.constraints = RigidbodyConstraints.FreezeRotationX | RigidbodyConstraints.FreezeRotationZ;

            var collider = root.AddComponent<BoxCollider>();
            collider.size = new Vector3(2.2f, 1.8f, 4.6f);
            collider.center = new Vector3(0f, 0.8f, 0f);

            root.AddComponent<VehicleController>();

            CreatePart(root.transform, "Body", new Vector3(0f, 0.75f, 0f), new Vector3(2.15f, 1.5f, 4.4f), new Color(0.92f, 0.94f, 0.95f));
            CreatePart(root.transform, "Cab", new Vector3(0f, 1.65f, 0.85f), new Vector3(2f, 0.9f, 1.8f), new Color(0.05f, 0.16f, 0.24f));
            CreatePart(root.transform, "BrandStripe", new Vector3(0f, 0.8f, -2.23f), new Vector3(1.5f, 0.45f, 0.05f), Orange);

            return root;
        }

        private static void CreatePart(Transform parent, string name, Vector3 position, Vector3 scale, Color color)
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            go.name = name;
            go.transform.SetParent(parent, false);
            go.transform.localPosition = position;
            go.transform.localScale = scale;
            Destroy(go.GetComponent<Collider>());
            go.GetComponent<Renderer>().material = new Material(Shader.Find("Standard")) { color = color };
        }

        private static void CreateCamera(Transform target)
        {
            var go = new GameObject("Main Camera", typeof(Camera), typeof(AudioListener), typeof(VehicleCamera));
            go.tag = "MainCamera";
            go.GetComponent<Camera>().fieldOfView = 62f;
            go.GetComponent<VehicleCamera>().Target = target;
            go.transform.position = target.position + new Vector3(0f, 4f, -8f);
        }

        private static void CreateLighting()
        {
            var go = new GameObject("Sun", typeof(Light));
            var light = go.GetComponent<Light>();
            light.type = LightType.Directional;
            light.intensity = 1.1f;
            light.color = new Color(1f, 0.90f, 0.75f);
            go.transform.rotation = Quaternion.Euler(42f, -25f, 0f);
        }

        private static void EnsureEventSystem()
        {
            if (FindFirstObjectByType<EventSystem>() == null)
                new GameObject("EventSystem", typeof(EventSystem), typeof(StandaloneInputModule));
        }
    }
}
