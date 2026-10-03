using System;
using System.Web;

namespace AirlineReservationSystem
{
    public static class UserStateHelper
    {
        public static bool IsLoggedIn
        {
            get
            {
                var session = HttpContext.Current.Session;
                return session != null && session["UserId"] != null;
            }
        }

        public static bool IsGuest
        {
            get
            {
                var session = HttpContext.Current.Session;
                if (session == null) return true;
                if (session["UserId"] != null) return false;
                return true;
            }
        }

        public static string CurrentUsername
        {
            get
            {
                var session = HttpContext.Current.Session;
                if (session != null && session["Username"] != null)
                {
                    return session["Username"].ToString();
                }
                return "Guest User";
            }
        }

        public static string CurrentFullName
        {
            get
            {
                var session = HttpContext.Current.Session;
                if (session != null && session["FullName"] != null)
                {
                    return session["FullName"].ToString();
                }
                return "Guest Passenger";
            }
        }

        public static string CurrentRole
        {
            get
            {
                var session = HttpContext.Current.Session;
                if (session != null && session["Role"] != null)
                {
                    return session["Role"].ToString();
                }
                return "Guest";
            }
        }

        public static bool IsAdmin
        {
            get
            {
                if (!IsLoggedIn) return false;
                string role = CurrentRole;
                return role.Equals("Admin", StringComparison.OrdinalIgnoreCase) ||
                       role.Equals("Clerk", StringComparison.OrdinalIgnoreCase);
            }
        }

        public static int CurrentUserId
        {
            get
            {
                var session = HttpContext.Current.Session;
                if (session != null && session["UserId"] != null)
                {
                    int uid;
                    if (int.TryParse(session["UserId"].ToString(), out uid))
                    {
                        return uid;
                    }
                }
                return 0;
            }
        }

        public static int CurrentSkyMiles
        {
            get
            {
                var session = HttpContext.Current.Session;
                if (session != null && session["SkyMiles"] != null)
                {
                    int miles;
                    if (int.TryParse(session["SkyMiles"].ToString(), out miles))
                    {
                        return miles;
                    }
                }
                return 0;
            }
        }

        public static void SetLoggedIn(int userId, string username, string fullName, string role, int skyMiles)
        {
            var session = HttpContext.Current.Session;
            if (session != null)
            {
                session["UserId"] = userId;
                session["Username"] = username;
                session["FullName"] = fullName;
                session["Role"] = role;
                session["SkyMiles"] = skyMiles;
                session["IsGuest"] = false;
            }
        }

        public static void SetGuest()
        {
            var session = HttpContext.Current.Session;
            if (session != null)
            {
                session.Clear();
                session["IsGuest"] = true;
                session["Username"] = "Guest";
                session["FullName"] = "Guest Passenger";
            }
        }

        public static void Logout()
        {
            var session = HttpContext.Current.Session;
            if (session != null)
            {
                session.Clear();
                session.Abandon();
            }
        }
    }
}
