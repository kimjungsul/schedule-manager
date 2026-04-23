private readonly ApplicationDbContext _ctx; public ProjectsController(ApplicationDbContext ctx) => _ctx = ctx;
    [HttpGet] public async Task<IActionResult> Get() => Ok(await _ctx.Projects.ToListAsync());
    [HttpPost] public async Task<IActionResult> Post([FromBody] Project p) { _ctx.Projects.Add(p); await _ctx.SaveChangesAsync(); return Ok(p); }
}
