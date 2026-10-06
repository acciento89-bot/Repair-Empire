using UnityEngine;

namespace Kamilunavo.RepairEmpire.Gameplay
{
    public sealed class CityBuilder : MonoBehaviour
    {
        private static readonly Color Road = new(0.16f, 0.17f, 0.18f);
        private static readonly Color Sidewalk = new(0.56f, 0.57f, 0.55f);
        private static readonly Color Navy = new(0.03f, 0.10f, 0.16f);
        private static readonly Color Orange = new(1f, 0.30f, 0.05f);
        private static readonly Color Cyan = new(0.05f, 0.66f, 1f);

        public void Build()
        {
            Random.InitState(260906);
            CreateBox("Road", new Vector3(0f, -0.25f, 220f), new Vector3(16f, 0.5f, 470f), Road, true);
            CreateBox("SidewalkL", new Vector3(-10f, 0f, 220f), new Vector3(4f, 0.35f, 470f), Sidewalk, true);
            CreateBox("SidewalkR", new Vector3(10f, 0f, 220f), new Vector3(4f, 0.35f, 470f), Sidewalk, true);

            for (var z = 10; z < 450; z += 22)
            {
                BuildBuilding(-16f, z);
                BuildBuilding(16f, z);
            }

            BuildWorkshop();

            for (var z = 25; z < 420; z += 16)
                CreateBox("RouteArrow", new Vector3(0f, 0.04f, z), new Vector3(1.6f, 0.05f, 4f), Cyan, false);

            var marker = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
            marker.name = "DestinationMarker";
            marker.transform.position = new Vector3(0f, 2f, 284f);
            marker.transform.localScale = new Vector3(1.4f, 2.5f, 1.4f);
            marker.GetComponent<Renderer>().material = Material(Orange);
            Object.Destroy(marker.GetComponent<Collider>());
        }

        private static void BuildBuilding(float x, float z)
        {
            var h = Random.Range(8f, 18f);
            var color = Random.value > 0.5f ? Navy : new Color(0.34f, 0.39f, 0.44f);
            CreateBox("Building", new Vector3(x, h * 0.5f, z), new Vector3(8f, h, 14f), color, true);
        }

        private static void BuildWorkshop()
        {
            CreateBox("RepairEmpireWorkshop", new Vector3(14f, 3.5f, 35f), new Vector3(12f, 7f, 20f), Navy, true);
            CreateBox("WorkshopAccent", new Vector3(8.3f, 3.5f, 35f), new Vector3(0.4f, 4.5f, 15f), Orange, false);
        }

        private static GameObject CreateBox(string name, Vector3 position, Vector3 scale, Color color, bool collider)
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            go.name = name;
            go.transform.position = position;
            go.transform.localScale = scale;
            go.GetComponent<Renderer>().material = Material(color);
            if (!collider) Object.Destroy(go.GetComponent<Collider>());
            return go;
        }

        private static Material Material(Color color) => new(Shader.Find("Standard")) { color = color };
    }
}
