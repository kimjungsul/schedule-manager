using System.ComponentModel.DataAnnotations;
namespace ScheduleManager.Api.Models {[오후 12:31]public class User { [Key] public int UserId { get; set; } [Required] public string Name { get; set; } = ""; [Required] public string Email { get; set; } = ""; [Required] public string Role { get; set; } = "Dev"; public string? SlackId { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; }
}
