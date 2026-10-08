namespace Kamilunavo.RepairEmpire.Gameplay
{
    [System.Serializable]
    public sealed class JobDefinition
    {
        public string Id;
        public string Title;
        public string Category;
        public string Address;
        public int Reward;
        public int Xp;
        public float DestinationZ;
        public string RequiredTool;
        public string TitleDe;
        public int CategoryIndex, MinimumLevel=1, ToolTier;
        public float DestinationX;

        public JobDefinition(string id, string title, string category, string address, int reward, int xp, float destinationZ, string requiredTool)
        {
            Id = id;
            Title = title;
            Category = category;
            Address = address;
            Reward = reward;
            Xp = xp;
            DestinationZ = destinationZ;
            RequiredTool = requiredTool;
        }
    }
}
