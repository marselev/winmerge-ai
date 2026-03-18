///////////////////////////////////////////////////////////////////////////
//
// WinMerge:  an interactive diff/merge utility
//
// SPDX-License-Identifier: GPL-2.0-or-later
//
///////////////////////////////////////////////////////////////////////////
/**
 * @file  PropAIAutoMerge.cpp
 *
 * @brief Property page for AI Auto Merge settings
 */
#include "pch.h"
#include "PropAIAutoMerge.h"
#include "OptionsDef.h"
#include "OptionsMgr.h"
#include "resource.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// PropAIAutoMerge property page

IMPLEMENT_DYNAMIC(PropAIAutoMerge, OptionsPanel)

PropAIAutoMerge::PropAIAutoMerge(COptionsMgr* options)
    : OptionsPanel(options, PropAIAutoMerge::IDD)
    , m_bAIAutoMergeEnabled(FALSE)
    , m_nAIAutoMergeStrategy(1)  // Default to BALANCED
{
}

PropAIAutoMerge::~PropAIAutoMerge() = default;

void PropAIAutoMerge::DoDataExchange(CDataExchange* pDX)
{
    OptionsPanel::DoDataExchange(pDX);
    DDX_Check(pDX, IDC_AI_AUTO_MERGE_ENABLE, m_bAIAutoMergeEnabled);
    DDX_CBIndex(pDX, IDC_AI_AUTO_MERGE_STRATEGY, m_nAIAutoMergeStrategy);
}

BEGIN_MESSAGE_MAP(PropAIAutoMerge, OptionsPanel)
    ON_BN_CLICKED(IDC_AI_AUTO_MERGE_ENABLE, OnEnableAIAutoMergeClicked)
    ON_CBN_SELCHANGE(IDC_AI_AUTO_MERGE_STRATEGY, OnStrategyChanged)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// PropAIAutoMerge message handlers

BOOL PropAIAutoMerge::OnInitDialog()
{
    OptionsPanel::OnInitDialog();

    // Populate strategy combo box
    CComboBox* pCombo = (CComboBox*)GetDlgItem(IDC_AI_AUTO_MERGE_STRATEGY);
    if (pCombo)
    {
        auto names = AIAutoMergeManager::GetAllStrategyNames();
        for (const auto& name : names)
        {
            pCombo->AddString(name.c_str());
        }
    }

    UpdateControls();
    return TRUE;
}

void PropAIAutoMerge::ReadOptions()
{
    m_bAIAutoMergeEnabled = GetOptionsMgr()->GetBool(OPT_AI_AUTO_MERGE_ENABLED) ? TRUE : FALSE;
    m_nAIAutoMergeStrategy = GetOptionsMgr()->GetInt(OPT_AI_AUTO_MERGE_STRATEGY);
    
    // Ensure strategy is in valid range
    if (m_nAIAutoMergeStrategy < 0 || m_nAIAutoMergeStrategy > 3)
    {
        m_nAIAutoMergeStrategy = 1;  // Default to BALANCED
    }
}

void PropAIAutoMerge::WriteOptions()
{
    UpdateData();
    
    GetOptionsMgr()->SaveOption(OPT_AI_AUTO_MERGE_ENABLED, m_bAIAutoMergeEnabled == TRUE);
    GetOptionsMgr()->SaveOption(OPT_AI_AUTO_MERGE_STRATEGY, m_nAIAutoMergeStrategy);
    
    // Update the global AI Auto Merge manager
    AIAutoMergeManager* pManager = GetAIAutoMergeManager();
    if (pManager)
    {
        pManager->SetEnabled(m_bAIAutoMergeEnabled == TRUE);
        pManager->SetStrategy(static_cast<AIAutoMergeStrategy>(m_nAIAutoMergeStrategy));
    }
}

void PropAIAutoMerge::OnEnableAIAutoMergeClicked()
{
    UpdateData();
    UpdateControls();
}

void PropAIAutoMerge::OnStrategyChanged()
{
    UpdateData();
}

void PropAIAutoMerge::UpdateControls()
{
    // Enable/disable strategy combo based on enabled checkbox
    CWnd* pStrategyLabel = GetDlgItem(IDC_AI_AUTO_MERGE_STRATEGY_LABEL);
    CWnd* pStrategyCombo = GetDlgItem(IDC_AI_AUTO_MERGE_STRATEGY);
    
    if (pStrategyLabel)
        pStrategyLabel->EnableWindow(m_bAIAutoMergeEnabled);
    if (pStrategyCombo)
        pStrategyCombo->EnableWindow(m_bAIAutoMergeEnabled);
}
