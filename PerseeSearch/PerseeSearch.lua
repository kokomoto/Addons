-- About PerseeSearch.lua
--
-- PerseeSearch.lua searches Loan Titles in Persee, a French website with dissertations and other full-text titles.
-- autoSearch (boolean) determines whether the search is performed automatically when a request is opened or not.
--



local settings = {};
settings.autoSearch = GetSetting("AutoSearch");
settings.StartwithTitle = GetSetting("StartwithTitle")
settings.StartwithAuthor = GetSetting("StartwithAuthor")
settings.StartwithISxN = GetSetting("StartwithISxN")
local interfaceMngr = nil;
local PerseeForm = {};
PerseeForm.Form = nil;
PerseeForm.Browser = nil;
PerseeForm.RibbonPage = nil;


function Init()

		--if GetFieldValue("Transaction", "RequestType") == "Loan" then
			interfaceMngr = GetInterfaceManager();
			
			-- Create browser
			PerseeForm.Form = interfaceMngr:CreateForm("Persee", "Script");
			PerseeForm.Browser = PerseeForm.Form:CreateBrowser("Persee", "Persee", "Persee");
			
			-- Hide the text label
			PerseeForm.Browser.TextVisible = false;
			
			--Suppress Javascript errors
			PerseeForm.Browser.WebBrowser.ScriptErrorsSuppressed = true;
			
			-- Since we didn't create a ribbon explicitly before creating our browser, it will have created one using the name we passed the CreateBrowser method.  We can retrieve that one and add our buttons to it.
			PerseeForm.RibbonPage = PerseeForm.Form:GetRibbonPage("Persee");
		    PerseeForm.RibbonPage:CreateButton("Search ISxN", GetClientImage("Search32"), "SearchISxN", "Persee");
			PerseeForm.RibbonPage:CreateButton("Search Title", GetClientImage("Search32"), "SearchTitle", "Persee");
			PerseeForm.RibbonPage:CreateButton("Search Author", GetClientImage("Search32"), "SearchAuthor", "Persee");
			
			PerseeForm.Form:Show();
            
			if settings.autoSearch then
			PerseeForm.Browser:Navigate("http://www.persee.fr/web/guest/home");
			  	if settings.StartwithISxN then
				   	PerseeForm.Browser:RegisterPageHandler("formExists", "btn_rechercher", "SearchISxN", false);
			    elseif settings.StartwithTitle then
					PerseeForm.Browser:RegisterPageHandler("formExists", "btn_rechercher", "SearchTitle", false);
				elseif settings.StartwithAuthor then
					PerseeForm.Browser:RegisterPageHandler("formExists", "btn_rechercher", "SearchAuthor", false);
				else
					PerseeForm.Browser:RegisterPageHandler("formExists", "btn_rechercher", "SearchTitle", false);
				end
			end
end

function SearchAuthor()
	if GetFieldValue("Transaction", "LoanAuthor") ~= "" then
		PerseeForm.Browser:SetFormValue("btn_rechercher", "accueil_recherche", GetFieldValue("Transaction", "LoanAuthor"));
		PerseeForm.Browser:SubmitForm("btn_rechercher");
	else
       interfaceMngr:ShowMessage("Author is not available from request form", "Insufficient Information");
	end
end

function SearchISxN()
	if GetFieldValue("Transaction", "ISSN") ~= "" then
		PerseeForm.Browser:SetFormValue("btn_rechercher", "accueil_recherche", GetFieldValue("Transaction", "ISSN"));
		PerseeForm.Browser:SubmitForm("btn_rechercher");
	else
       interfaceMngr:ShowMessage("ISxN is not available from request form", "Insufficient Information");
	end
end

function SearchTitle()
 if GetFieldValue("Transaction", "RequestType") == "Loan" then  
    if GetFieldValue("Transaction", "LoanTitle") ~= "" then  
     	PerseeForm.Browser:SetFormValue("btn_rechercher", "accueil_recherche", GetFieldValue("Transaction", "LoanTitle"));
		PerseeForm.Browser:SubmitForm("btn_rechercher");
	else
	    interfaceMngr:ShowMessage("Title is not available from request form", "Insufficient Information");
    end
else
	if GetFieldValue("Transaction", "PhotoArticleTitle") ~= "" then  
     	PerseeForm.Browser:SetFormValue("btn_rechercher", "accueil_recherche", GetFieldValue("Transaction", "PhotoArticleTitle"));
		PerseeForm.Browser:SubmitForm("btn_rechercher");
	else
	    interfaceMngr:ShowMessage("Title is not available from request form", "Insufficient Information");
    end
end
end