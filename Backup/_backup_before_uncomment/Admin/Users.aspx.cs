using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using AirlineReservationSystem;

public partial class Admin_Users : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UserStateHelper.IsLoggedIn)
        {
            Response.Redirect("~/Public/Login.aspx?msg=auth_required");
            return;
        }

        if (!UserStateHelper.IsAdmin)
        {
            Response.Redirect("~/User/Dashboard.aspx");
            return;
        }

        if (!IsPostBack)
        {
            BindUsers();
        }
    }

    private void BindUsers()
    {
        gvUsers.DataSource = AdminHelper.GetAllUsers("");
        gvUsers.DataBind();
    }

    protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int targetUserId = Convert.ToInt32(e.CommandArgument);
        string err;
        if (e.CommandName == "MakeClerk")
        {
            if (AdminHelper.UpdateUserRole(targetUserId, "Clerk", out err))
            {
                ShowAlert("User role updated to Clerk.", "info");
                BindUsers();
            }
            else
            {
                ShowAlert("Failed: " + err, "danger");
            }
        }
        else if (e.CommandName == "MakeAdmin")
        {
            if (AdminHelper.UpdateUserRole(targetUserId, "Admin", out err))
            {
                ShowAlert("User promoted to Administrator.", "success");
                BindUsers();
            }
            else
            {
                ShowAlert("Failed: " + err, "danger");
            }
        }
    }

    private void ShowAlert(string msg, string type)
    {
        pnlAlert.Visible = true;
        pnlAlert.CssClass = "alert alert-" + type + " alert-dismissible fade show";
        litAlertMsg.Text = msg;
    }
}
