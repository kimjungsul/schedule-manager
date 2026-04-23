using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
namespace ScheduleManager.Api.Models {
    public class TaskItem { [Key] public int TaskId { get; set; } [Required] public int ProjectId { get; set; } [ForeignKey("ProjectId")] public Project? Project { get; set; } public int? UserId { get; set; } [ForeignKey("UserId")] public User? User { get; set; } [Required] public string Title { get; set; } = ""; public string? Description { get; set; } [Required] public DateTime StartDate { get; set; } [Required] public DateTime EndDate { get; set; } [Required] public string Status { get; set; } = "Todo"; public int Priority { get; set; } = 3; public DateTime UpdatedAt { get; set; } = DateTime.UtcNow; }
}
