﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface ICRUDService<T, TSearch, TInsert, TUpdate> : IService<T, TSearch> where TSearch : class
    {
        Task<T> Insert(TInsert insert);
        Task<T> Update(int id, TUpdate update);
        Task<bool> Delete(int id);
    }
}
