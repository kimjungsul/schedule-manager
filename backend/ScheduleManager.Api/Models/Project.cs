using System.ComponentModel.DataAnnotations;
namespace ScheduleManager.Api.Models {
    public class Project { [Key] public int ProjectId { get; set; } [Required] public string ProjectName { get; set; } = ""; public string? Description { get; set; } [Required] public DateTime StartDate { get; set; } [Required] public DateTime EndDate { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; }
}
