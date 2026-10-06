using UnityEngine;
using Kamilunavo.RepairEmpire.Gameplay;

namespace Kamilunavo.RepairEmpire.UI
{
    public sealed class TabletController : MonoBehaviour
    {
        public RepairGame Game;
        public VehicleController Vehicle;
        public RectTransform Root;

        private RectTransform _content;

        private static readonly Color Navy = new(0.025f, 0.085f, 0.14f, 0.99f);
        private static readonly Color Panel = new(0.045f, 0.14f, 0.22f, 0.99f);
        private static readonly Color Orange = new(1f, 0.32f, 0.07f);
        private static readonly Color White = new(0.97f, 0.99f, 1f);
        private static readonly Color Muted = new(0.69f, 0.78f, 0.86f);

        public void Toggle() => SetOpen(!Root.gameObject.activeSelf);

        public void SetOpen(bool open)
        {
            Root.gameObject.SetActive(open);
            if (Vehicle != null) Vehicle.InputEnabled = !open;
            if (open) Show(0);
        }

        public void Build()
        {
            var tabs = new[] { "Jobs", "Tools", "Vehicles", "Workshop", "Employees", "Daily" };
            for (var i = 0; i < tabs.Length; i++)
            {
                var index = i;
                var min = 0.03f + i * 0.158f;
                UiFactory.Button(Root, "Tab_" + tabs[i], tabs[i], i == 0 ? Orange : Panel, White, new Vector2(min, 0.82f), new Vector2(min + 0.148f, 0.91f), () => Show(index));
            }

            UiFactory.Button(Root, "Close", "X", Panel, White, new Vector2(0.90f, 0.92f), new Vector2(0.97f, 0.98f), () => SetOpen(false));
            _content = UiFactory.Panel(Root, "Content", Panel, new Vector2(0.03f, 0.05f), new Vector2(0.97f, 0.80f));
        }

        private void Show(int index)
        {
            Clear();
            if (index == 0)
            {
                ShowJobs();
                return;
            }

            var names = new[] { "", "TOOLS", "VEHICLES", "WORKSHOP", "EMPLOYEES", "DAILY JOBS" };
            var bodies = new[]
            {
                "",
                "Basic Wrench  •  owned\nVoltage Tester  •  unlock next\nPipe Wrench  •  locked",
                "Compact Service Van  •  active\nCargo Van  •  locked\nElectric Service Van  •  locked",
                "Workshop Level 1\nNext: Tool Storage +10%",
                "No employees yet\nHire assistants after Level 4",
                "Daily: Complete 3 service calls\nReward: $250 + 150 XP"
            };

            UiFactory.Label(_content, "Heading", names[index], 40, new Vector2(0.06f, 0.78f), new Vector2(0.94f, 0.94f), TextAnchor.MiddleLeft, Orange, FontStyle.Bold);
            UiFactory.Label(_content, "Body", bodies[index], 30, new Vector2(0.06f, 0.30f), new Vector2(0.94f, 0.76f), TextAnchor.UpperLeft, White);
        }

        private void ShowJobs()
        {
            UiFactory.Label(_content, "Heading", "AVAILABLE SERVICE CALLS", 34, new Vector2(0.04f, 0.87f), new Vector2(0.96f, 0.98f), TextAnchor.MiddleLeft, Orange, FontStyle.Bold);

            for (var i = 0; i < Game.Jobs.Count; i++)
            {
                var job = Game.Jobs[i];
                var yMax = 0.84f - i * 0.17f;
                var yMin = yMax - 0.145f;
                UiFactory.Button(_content, "Job_" + job.Id, job.Title + "\n" + job.Category + "   •   $" + job.Reward + "   •   " + job.Xp + " XP", Navy, White, new Vector2(0.04f, yMin), new Vector2(0.58f, yMax), () =>
                {
                    Game.SelectJob(job);
                    Show(0);
                });
            }

            var active = Game.ActiveJob;
            var detail = UiFactory.Panel(_content, "Detail", Navy, new Vector2(0.61f, 0.16f), new Vector2(0.96f, 0.84f));
            UiFactory.Label(detail, "Title", active.Title, 38, new Vector2(0.06f, 0.74f), new Vector2(0.94f, 0.92f), TextAnchor.MiddleLeft, White, FontStyle.Bold);
            UiFactory.Label(detail, "Meta",
                active.Category + "\n" + active.Address + "\n\nReward   $" + active.Reward + "\nXP       " + active.Xp + "\nTool     " + active.RequiredTool,
                27, new Vector2(0.06f, 0.28f), new Vector2(0.94f, 0.73f), TextAnchor.UpperLeft, Muted);
            UiFactory.Button(detail, "Start", "START JOB", Orange, White, new Vector2(0.08f, 0.06f), new Vector2(0.92f, 0.22f), () => SetOpen(false));
        }

        private void Clear()
        {
            if (_content == null) return;
            for (var i = _content.childCount - 1; i >= 0; i--) Destroy(_content.GetChild(i).gameObject);
        }
    }
}
