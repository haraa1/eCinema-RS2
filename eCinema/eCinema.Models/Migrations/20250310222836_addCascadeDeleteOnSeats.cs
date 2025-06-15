using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCinema.Models.Migrations
{
    /// <inheritdoc />
    public partial class addCascadeDeleteOnSeats : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Seats_CinemaHalls_CinemaHallId",
                table: "Seats");


            migrationBuilder.AddForeignKey(
                name: "FK_Seats_CinemaHalls_CinemaHallId",
                table: "Seats",
                column: "CinemaHallId",
                principalTable: "CinemaHalls",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Seats_CinemaHalls_CinemaHallId",
                table: "Seats");

            migrationBuilder.AddForeignKey(
                name: "FK_Seats_CinemaHalls_CinemaHallId",
                table: "Seats",
                column: "CinemaHallId",
                principalTable: "CinemaHalls",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
