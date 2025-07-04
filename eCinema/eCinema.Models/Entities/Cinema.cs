﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Model.Entities
{
    public class Cinema
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string City { get; set; }
        public string Address { get; set; }

        public ICollection<CinemaHall> CinemaHalls { get; set; }
    }
}
