using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace eCinema.Models.Migrations
{
    /// <inheritdoc />
    public partial class addSeatType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Type",
                table: "Seats");

            migrationBuilder.AddColumn<int>(
                name: "SeatTypeId",
                table: "Seats",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "SeatsType",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    PriceMultiplier = table.Column<decimal>(type: "decimal(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SeatsType", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "SeatsType",
                columns: new[] { "Id", "Name", "PriceMultiplier" },
                values: new object[,]
                {
                    { 1, "Standard", 1.0m },
                    { 2, "Love Seat", 1.0m },
                    { 3, "VIP", 1.5m }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Seats_SeatTypeId",
                table: "Seats",
                column: "SeatTypeId");

            migrationBuilder.AddForeignKey(
                name: "FK_Seats_SeatsType_SeatTypeId",
                table: "Seats",
                column: "SeatTypeId",
                principalTable: "SeatsType",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Seats_SeatsType_SeatTypeId",
                table: "Seats");

            migrationBuilder.DropTable(
                name: "SeatsType");

            migrationBuilder.DropIndex(
                name: "IX_Seats_SeatTypeId",
                table: "Seats");

            migrationBuilder.DropColumn(
                name: "SeatTypeId",
                table: "Seats");

            migrationBuilder.AddColumn<string>(
                name: "Type",
                table: "Seats",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");
        }
    }
}
