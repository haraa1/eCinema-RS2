using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCinema.Models.Migrations
{
    /// <inheritdoc />
    public partial class addNotifyAngLanguageFieldInUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "Notify",
                table: "User",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "PreferredLanguage",
                table: "User",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Notify",
                table: "User");

            migrationBuilder.DropColumn(
                name: "PreferredLanguage",
                table: "User");
        }
    }
}
