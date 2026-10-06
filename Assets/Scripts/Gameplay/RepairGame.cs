using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace Kamilunavo.RepairEmpire.Gameplay
{
    public sealed class RepairGame : MonoBehaviour
    {
        public VehicleController Vehicle;
        public Text CashText;
        public Text LevelText;
        public Text ToolText;
        public Text JobTitle;
        public Text JobMeta;
        public Text DistanceText;
        public Text StatusText;
        public Button CompleteButton;

        public readonly List<JobDefinition> Jobs = new();
        public JobDefinition ActiveJob { get; private set; }

        public int Cash { get; private set; } = 1130;
        public int Level { get; private set; } = 2;
        public int Xp { get; private set; } = 124;
        public int XpTarget { get; private set; } = 143;

        private bool _arrived;

        private void Awake()
        {
            Jobs.Add(new JobDefinition("faucet", "Leaking Faucet", "Plumbing • Residential", "Riverside Apartments", 120, 100, 284f, "Basic Wrench"));
            Jobs.Add(new JobDefinition("toilet", "Running Toilet", "Plumbing • Residential", "Oak Street", 150, 120, 330f, "Basic Wrench"));
            Jobs.Add(new JobDefinition("switch", "Broken Light Switch", "Electrical • Residential", "Market Lofts", 110, 90, 370f, "Voltage Tester"));
            Jobs.Add(new JobDefinition("sink", "Clogged Sink", "Plumbing • Residential", "Park View", 180, 140, 410f, "Basic Wrench"));
            ActiveJob = Jobs[0];
        }

        private void Start() => Refresh();

        private void Update()
        {
            if (Vehicle == null || ActiveJob == null) return;
            var distance = Mathf.Abs(ActiveJob.DestinationZ - Vehicle.transform.position.z);
            DistanceText.text = Mathf.CeilToInt(distance) + " m";
            _arrived = distance < 8f;
            if (StatusText != null) StatusText.text = _arrived ? "ARRIVED • READY TO REPAIR" : Vehicle.SpeedKmh.ToString("0") + " KM/H";
            if (CompleteButton != null) CompleteButton.gameObject.SetActive(_arrived);
        }

        public void SelectJob(JobDefinition job)
        {
            ActiveJob = job;
            _arrived = false;
            Refresh();
        }

        public void CompleteActiveJob()
        {
            if (!_arrived || ActiveJob == null) return;

            Cash += ActiveJob.Reward;
            Xp += ActiveJob.Xp;
            while (Xp >= XpTarget)
            {
                Xp -= XpTarget;
                Level++;
                XpTarget = 100 + Level * 22;
            }

            _arrived = false;
            Vehicle.transform.position = new Vector3(0f, 1.2f, 0f);
            Vehicle.transform.rotation = Quaternion.identity;
            Vehicle.ResetMotion();
            Refresh();
        }

        private void Refresh()
        {
            CashText.text = "CASH\n$" + Cash.ToString("N0");
            LevelText.text = "LEVEL " + Level + "\n" + Xp + " / " + XpTarget + " XP";
            ToolText.text = "TOOL\n" + (ActiveJob != null ? ActiveJob.RequiredTool : "Basic Wrench");
            JobTitle.text = "SERVICE CALL\n" + (ActiveJob != null ? ActiveJob.Title : "Choose a job");
            JobMeta.text = ActiveJob != null ? ActiveJob.Address + "\n$" + ActiveJob.Reward + "   •   " + ActiveJob.Xp + " XP" : "";
        }
    }
}
