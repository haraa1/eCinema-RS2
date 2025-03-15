using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCinema.Models.Migrations
{
    /// <inheritdoc />
    public partial class databaseUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Seats_SeatsType_SeatTypeId",
                table: "Seats");

            migrationBuilder.DropPrimaryKey(
                name: "PK_SeatsType",
                table: "SeatsType");

            migrationBuilder.RenameTable(
                name: "SeatsType",
                newName: "SeatTypes");

            migrationBuilder.AddPrimaryKey(
                name: "PK_SeatTypes",
                table: "SeatTypes",
                column: "Id");

            migrationBuilder.CreateTable(
                name: "Concessions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Concessions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Showtime",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MovieId = table.Column<int>(type: "int", nullable: false),
                    CinemaHallId = table.Column<int>(type: "int", nullable: false),
                    StartTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    BasePrice = table.Column<decimal>(type: "decimal(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Showtime", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Showtime_CinemaHalls_CinemaHallId",
                        column: x => x.CinemaHallId,
                        principalTable: "CinemaHalls",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Showtime_Movies_MovieId",
                        column: x => x.MovieId,
                        principalTable: "Movies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "TicketType",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    PriceModifier = table.Column<decimal>(type: "decimal(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TicketType", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "User",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PasswordSalt = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_User", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Bookings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ShowtimeId = table.Column<int>(type: "int", nullable: false),
                    BookingTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    DiscountCode = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Bookings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Bookings_Showtime_ShowtimeId",
                        column: x => x.ShowtimeId,
                        principalTable: "Showtime",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Bookings_User_UserId",
                        column: x => x.UserId,
                        principalTable: "User",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "BookingConcessions",
                columns: table => new
                {
                    BookingId = table.Column<int>(type: "int", nullable: false),
                    ConcessionId = table.Column<int>(type: "int", nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BookingConcessions", x => new { x.BookingId, x.ConcessionId });
                    table.ForeignKey(
                        name: "FK_BookingConcessions_Bookings_BookingId",
                        column: x => x.BookingId,
                        principalTable: "Bookings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_BookingConcessions_Concessions_ConcessionId",
                        column: x => x.ConcessionId,
                        principalTable: "Concessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Ticket",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BookingId = table.Column<int>(type: "int", nullable: false),
                    SeatId = table.Column<int>(type: "int", nullable: false),
                    TicketTypeId = table.Column<int>(type: "int", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Ticket", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Ticket_Bookings_BookingId",
                        column: x => x.BookingId,
                        principalTable: "Bookings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Ticket_Seats_SeatId",
                        column: x => x.SeatId,
                        principalTable: "Seats",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Ticket_TicketType_TicketTypeId",
                        column: x => x.TicketTypeId,
                        principalTable: "TicketType",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_BookingConcessions_ConcessionId",
                table: "BookingConcessions",
                column: "ConcessionId");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_ShowtimeId",
                table: "Bookings",
                column: "ShowtimeId");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_UserId",
                table: "Bookings",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Showtime_CinemaHallId",
                table: "Showtime",
                column: "CinemaHallId");

            migrationBuilder.CreateIndex(
                name: "IX_Showtime_MovieId",
                table: "Showtime",
                column: "MovieId");

            migrationBuilder.CreateIndex(
                name: "IX_Ticket_BookingId",
                table: "Ticket",
                column: "BookingId");

            migrationBuilder.CreateIndex(
                name: "IX_Ticket_SeatId",
                table: "Ticket",
                column: "SeatId");

            migrationBuilder.CreateIndex(
                name: "IX_Ticket_TicketTypeId",
                table: "Ticket",
                column: "TicketTypeId");

            migrationBuilder.AddForeignKey(
                name: "FK_Seats_SeatTypes_SeatTypeId",
                table: "Seats",
                column: "SeatTypeId",
                principalTable: "SeatTypes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Seats_SeatTypes_SeatTypeId",
                table: "Seats");

            migrationBuilder.DropTable(
                name: "BookingConcessions");

            migrationBuilder.DropTable(
                name: "Ticket");

            migrationBuilder.DropTable(
                name: "Concessions");

            migrationBuilder.DropTable(
                name: "Bookings");

            migrationBuilder.DropTable(
                name: "TicketType");

            migrationBuilder.DropTable(
                name: "Showtime");

            migrationBuilder.DropTable(
                name: "User");

            migrationBuilder.DropPrimaryKey(
                name: "PK_SeatTypes",
                table: "SeatTypes");

            migrationBuilder.RenameTable(
                name: "SeatTypes",
                newName: "SeatsType");

            migrationBuilder.AddPrimaryKey(
                name: "PK_SeatsType",
                table: "SeatsType",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Seats_SeatsType_SeatTypeId",
                table: "Seats",
                column: "SeatTypeId",
                principalTable: "SeatsType",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
