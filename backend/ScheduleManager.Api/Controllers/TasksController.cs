using Microsoft.AspNetCore.Mvc; using Microsoft.EntityFrameworkCore; using ScheduleManager.Api.Data; using ScheduleManager.Api.Models;
[ApiController] [Route("api/v1/[controller]")] public class TasksController : ControllerBase {
    private readonly ApplicationDbContext _ctx; public TasksController(ApplicationDbContext ctx) => _ctx = ctx;
    [HttpGet("my")] public async Task<IActionResult> My([FromQuery] int userId) => Ok(await _ctx.Tasks.Where(t => t.UserId == userId).ToListAsync());
    [HttpGet] public async Task<IActionResult> All() => Ok(await _ctx.Tasks.Include(t => t.User).ToListAsync());
    [HttpPost] public async Task<IActionResult> Post([FromBody] TaskItem t) { _ctx.Tasks.Add(t); await _ctx.SaveChangesAsync(); return Ok(t); }
    [HttpPut("{id}")] public async Task<IActionResult> Put(int id, [FromBody] TaskItem t) {
        var exist = await _ctx.Tasks.FindAsync(id); if(exist == null) return NotFound();
        exist.Status = t.Status; exist.Title = t.Title; await _ctx.SaveChangesAsync(); return Ok(exist);
    }
    [HttpDelete("{id}")] public async Task<IActionResult> Del(int id) {
        var tsk = await _ctx.Tasks.FindAsync(id); if(tsk == null) return NotFound();
        _ctx.Tasks.Remove(tsk); await _ctx.SaveChangesAsync(); return NoContent();
    }
}
