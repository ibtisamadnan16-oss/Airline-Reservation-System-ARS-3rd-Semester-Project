using System;
using System.Data;
using System.Web.UI;
using AirlineReservationSystem;

public partial class Admin_Reservations : Page
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
            BindReservations();
        }
    }

    private void BindReservations(string status = "ALL", string code = "")
    {
        gvReservations.DataSource = AdminHelper.GetAllReservations(status, code);
        gvReservations.DataBind();
    }

    protected void ddlFilterStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindReservations(ddlFilterStatus.SelectedValue, txtSearchCode.Text.Trim());
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindReservations(ddlFilterStatus.SelectedValue, txtSearchCode.Text.Trim());
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtSearchCode.Text = "";
        ddlFilterStatus.SelectedValue = "ALL";
        BindReservations();
    }

    protected string GetBadge(string status)
    {
        switch (status.ToLower())
        {
            case "confirmed": return "bg-success";
            case "blocked": return "bg-warning text-dark";
            case "cancelled": return "bg-danger";
            default: return "bg-secondary";
        }
    }
}
