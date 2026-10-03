using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace AirlineReservationSystem
{
    public static class DbHelper
    {
        private static readonly string ConnectionString;

        static DbHelper()
        {
            ConnectionString = ConfigurationManager.ConnectionStrings["AirlineDbConn"] != null
                ? ConfigurationManager.ConnectionStrings["AirlineDbConn"].ConnectionString
                : "Server=(localdb)\\MSSQLLocalDB;Database=AirlineReservationDB;Integrated Security=True;";
        }

        public static SqlConnection GetConnection()
        {
            return new SqlConnection(ConnectionString);
        }

        public static DataTable ExecuteQuery(string query, SqlParameter[] parameters = null)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = GetConnection())
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            return dt;
        }

        public static int ExecuteNonQuery(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public static object ExecuteScalar(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    return cmd.ExecuteScalar();
                }
            }
        }

        public static bool TestConnection(out string error)
        {
            try
            {
                using (SqlConnection conn = GetConnection())
                {
                    conn.Open();
                    error = null;
                    return true;
                }
            }
            catch (Exception ex)
            {
                error = ex.Message;
                return false;
            }
        }
    }
}
