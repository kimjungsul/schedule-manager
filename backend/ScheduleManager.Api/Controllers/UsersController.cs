using Microsoft.AspNetCore.Mvc; using Microsoft.EntityFrameworkCore; using ScheduleManager.Api.Data; using ScheduleManager.Api.Models;
[ApiController] [Route("api/v1/[controller]")] public class UsersController : ControllerBase {
    private readonly ApplicationDbContext _ctx; public UsersController(ApplicationDbContext ctx) => _ctx = ctx;
    [HttpPost("register")] public async Task<IActionResult> Reg([FromBody] User u) { _ctx.Users.Add(u); await _ctx.SaveChangesAsync(); return Ok(u); }
[HttpGet] public async Task<IActionResult> Get() => Ok(await _ctx.Users.ToListAsync());
}
