using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace eCinema.Models.Migrations
{
    /// <inheritdoc />
    public partial class seedtest : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Concessions",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Concessions",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Concessions",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Discounts",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Discounts",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Showtime",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Showtime",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "CinemaHalls",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "CinemaHalls",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Cinemas",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Cinemas",
                keyColumn: "Id",
                keyValue: 2);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Cinemas",
                columns: new[] { "Id", "Address", "City", "Name" },
                values: new object[,]
                {
                    { 1, "Main St 1", "Sarajevo", "City Cinema" },
                    { 2, "River Rd 5", "Mostar", "River Cinema" }
                });

            migrationBuilder.InsertData(
                table: "Concessions",
                columns: new[] { "Id", "Description", "Name", "Price" },
                values: new object[,]
                {
                    { 1, "Salted popcorn", "Popcorn", 3.50m },
                    { 2, "330ml Coke", "Soda", 2.00m },
                    { 3, "Cheesy nachos", "Nachos", 4.00m }
                });

            migrationBuilder.InsertData(
                table: "Discounts",
                columns: new[] { "Id", "Code", "DiscountPercentage", "IsActive", "ValidFrom", "ValidTo" },
                values: new object[,]
                {
                    { 1, "DISC10", 10m, false, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 2, "DISC20", 20m, false, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Genres",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Action" },
                    { 2, "Comedy" },
                    { 3, "Drama" }
                });

            migrationBuilder.InsertData(
                table: "Movies",
                columns: new[] { "Id", "Description", "DurationMinutes", "Language", "PgRating", "PosterImage", "ReleaseDate", "Status", "Title" },
                values: new object[,]
                {
                    { 1, "An epic journey.", 120, "EN", 1, null, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "The Great Adventure" },
                    { 2, "Non-stop laughs.", 90, "EN", 1, null, new DateTime(2024, 5, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "Laugh Riot" }
                });

            migrationBuilder.InsertData(
                table: "CinemaHalls",
                columns: new[] { "Id", "Capacity", "CinemaId", "Name" },
                values: new object[,]
                {
                    { 1, 100, 1, "Hall A" },
                    { 2, 150, 2, "Hall B" }
                });

            migrationBuilder.InsertData(
                table: "Showtime",
                columns: new[] { "Id", "BasePrice", "CinemaHallId", "EndTime", "MovieId", "StartTime" },
                values: new object[,]
                {
                    { 1, 8.00m, 1, new DateTime(2025, 5, 20, 16, 0, 0, 0, DateTimeKind.Unspecified), 1, new DateTime(2025, 5, 20, 14, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 2, 6.50m, 2, new DateTime(2025, 5, 20, 18, 30, 0, 0, DateTimeKind.Unspecified), 2, new DateTime(2025, 5, 20, 17, 0, 0, 0, DateTimeKind.Unspecified) }
                });
        }
    }
}
