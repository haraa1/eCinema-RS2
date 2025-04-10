using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCinema.Models.Migrations
{
    /// <inheritdoc />
    public partial class addisAvailableToSeat : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "isAvailable",
                table: "Seats",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "isAvailable",
                table: "Seats");
        }
    }
}
