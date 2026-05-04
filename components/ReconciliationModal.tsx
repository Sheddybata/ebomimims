"use client";

import { useState } from "react";
import {
  X,
  CheckCircle2,
  XCircle,
  Search,
  Filter,
  Calendar,
  Wallet,
  Receipt,
  AlertCircle,
  FileText,
  Download,
  Plus,
  Trash2,
  Eye,
  Check,
  Clock,
} from "lucide-react";

interface Transaction {
  id: number;
  date: string;
  description: string;
  amount: number;
  type: "debit" | "credit";
  reference?: string;
  matched?: boolean;
  matchId?: number;
}

interface OutstandingItem {
  id: number;
  type: "check" | "receipt" | "deposit";
  date: string;
  description: string;
  amount: number;
  reference: string;
  status: "outstanding" | "cleared";
}

interface BankAccount {
  id: number;
  name: string;
  bank: string;
  accountNumber: string;
  balance: number;
}

interface ReconciliationModalProps {
  account: BankAccount | null;
  isOpen: boolean;
  onClose: () => void;
  onComplete: (reconciliationData: any) => void;
}

// Currency formatter
const formatNaira = (amount: number) => {
  if (amount >= 1000000) {
    return `₦${(amount / 1000000).toFixed(2)}M`;
  } else if (amount >= 1000) {
    return `₦${(amount / 1000).toFixed(1)}K`;
  }
  return `₦${amount.toLocaleString()}`;
};

export default function ReconciliationModal({
  account,
  isOpen,
  onClose,
  onComplete,
}: ReconciliationModalProps) {
  const [reconciliationDate, setReconciliationDate] = useState<string>(
    new Date().toISOString().split("T")[0]
  );
  const [statementBalance, setStatementBalance] = useState<number>(0);
  const [startingBalance, setStartingBalance] = useState<number>(0);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedType, setSelectedType] = useState<"all" | "debit" | "credit">("all");
  const [showMatched, setShowMatched] = useState(true);
  const [notes, setNotes] = useState("");
  const [selectedTransactions, setSelectedTransactions] = useState<Set<number>>(new Set());
  const [selectedOutstanding, setSelectedOutstanding] = useState<Set<number>>(new Set());

  // Sample bank statement transactions
  const [statementTransactions, setStatementTransactions] = useState<Transaction[]>([
    {
      id: 101,
      date: "2024-01-15",
      description: "Transfer from Lagos Coordinator",
      amount: 125000,
      type: "credit",
      reference: "TXN-2024-001",
      matched: false,
    },
    {
      id: 102,
      date: "2024-01-14",
      description: "Office Supplies Payment",
      amount: 45000,
      type: "debit",
      reference: "CHK-2024-001",
      matched: false,
    },
    {
      id: 103,
      date: "2024-01-13",
      description: "Salary Payment",
      amount: 550000,
      type: "debit",
      reference: "CHK-2024-002",
      matched: true,
      matchId: 8,
    },
    {
      id: 104,
      date: "2024-01-12",
      description: "Seed Offering - Revival",
      amount: 200000,
      type: "credit",
      reference: "TXN-2024-002",
      matched: true,
      matchId: 6,
    },
    {
      id: 105,
      date: "2024-01-11",
      description: "Utility Bill Payment",
      amount: 25000,
      type: "debit",
      reference: "CHK-2024-003",
      matched: false,
    },
  ]);

  // Sample outstanding items
  const [outstandingItems, setOutstandingItems] = useState<OutstandingItem[]>([
    {
      id: 201,
      type: "check",
      date: "2024-01-10",
      description: "Vendor Payment - Supplies",
      amount: 35000,
      reference: "CHK-2024-004",
      status: "outstanding",
    },
    {
      id: 202,
      type: "receipt",
      date: "2024-01-09",
      description: "Tithes Collection - Sunday Service",
      amount: 150000,
      reference: "RCP-2024-001",
      status: "outstanding",
    },
    {
      id: 203,
      type: "check",
      date: "2024-01-08",
      description: "Equipment Purchase",
      amount: 75000,
      reference: "CHK-2024-005",
      status: "outstanding",
    },
    {
      id: 204,
      type: "deposit",
      date: "2024-01-07",
      description: "Cash Deposit - Offering",
      amount: 95000,
      reference: "DEP-2024-001",
      status: "outstanding",
    },
  ]);

  // Calculate balances
  const calculateAdjustedBalance = () => {
    const outstandingCredits = outstandingItems
      .filter((item) => item.type === "receipt" || item.type === "deposit")
      .filter((item) => item.status === "outstanding")
      .reduce((sum, item) => sum + item.amount, 0);

    const outstandingDebits = outstandingItems
      .filter((item) => item.type === "check")
      .filter((item) => item.status === "outstanding")
      .reduce((sum, item) => sum + item.amount, 0);

    return statementBalance + outstandingCredits - outstandingDebits;
  };

  const adjustedBalance = calculateAdjustedBalance();
  const difference = adjustedBalance - (account?.balance || 0);

  // Filter transactions
  const filteredTransactions = statementTransactions.filter((tx) => {
    if (!showMatched && tx.matched) return false;
    if (selectedType !== "all" && tx.type !== selectedType) return false;
    if (searchQuery && !tx.description.toLowerCase().includes(searchQuery.toLowerCase()) && !tx.reference?.toLowerCase().includes(searchQuery.toLowerCase()))
      return false;
    return true;
  });

  const filteredOutstanding = outstandingItems.filter((item) => {
    if (searchQuery && !item.description.toLowerCase().includes(searchQuery.toLowerCase()) && !item.reference.toLowerCase().includes(searchQuery.toLowerCase()))
      return false;
    return true;
  });

  const handleMatchTransaction = (txId: number) => {
    setStatementTransactions((prev) =>
      prev.map((tx) => (tx.id === txId ? { ...tx, matched: !tx.matched } : tx))
    );
  };

  const handleClearOutstanding = (itemId: number) => {
    setOutstandingItems((prev) =>
      prev.map((item) =>
        item.id === itemId ? { ...item, status: item.status === "outstanding" ? "cleared" : "outstanding" } : item
      )
    );
  };

  const handleCompleteReconciliation = () => {
    const reconciliationData = {
      accountId: account?.id,
      reconciliationDate,
      statementBalance,
      adjustedBalance,
      bookBalance: account?.balance,
      difference,
      matchedTransactions: statementTransactions.filter((tx) => tx.matched),
      clearedItems: outstandingItems.filter((item) => item.status === "cleared"),
      notes,
    };

    onComplete(reconciliationData);
    onClose();
  };

  if (!isOpen || !account) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      {/* Backdrop */}
      <div className="fixed inset-0 bg-black bg-opacity-50 transition-opacity" onClick={onClose}></div>

      {/* Modal */}
      <div className="flex min-h-full items-center justify-center p-4">
        <div className="relative bg-white rounded-lg shadow-xl max-w-7xl w-full max-h-[90vh] overflow-hidden flex flex-col">
          {/* Header */}
          <div className="flex items-center justify-between p-6 border-b border-gray-200 bg-primary-50">
            <div>
              <h2 className="text-2xl font-bold text-gray-800">Account Reconciliation</h2>
              <p className="text-sm text-gray-600 mt-1">
                {account.name} • {account.bank} • {account.accountNumber}
              </p>
            </div>
            <button
              onClick={onClose}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <X size={24} className="text-gray-600" />
            </button>
          </div>

          {/* Content */}
          <div className="flex-1 overflow-y-auto p-6">
            {/* Reconciliation Controls */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
              <div className="p-4 bg-gray-50 rounded-lg">
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Reconciliation Date
                </label>
                <input
                  type="date"
                  value={reconciliationDate}
                  onChange={(e) => setReconciliationDate(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div className="p-4 bg-gray-50 rounded-lg">
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Statement Balance (₦)
                </label>
                <input
                  type="number"
                  value={statementBalance}
                  onChange={(e) => setStatementBalance(parseFloat(e.target.value) || 0)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  placeholder="Enter statement balance"
                />
              </div>
              <div className="p-4 bg-gray-50 rounded-lg">
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Starting Balance (₦)
                </label>
                <input
                  type="number"
                  value={startingBalance}
                  onChange={(e) => setStartingBalance(parseFloat(e.target.value) || 0)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  placeholder="Enter starting balance"
                />
              </div>
            </div>

            {/* Balance Summary */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
              <div className="p-4 bg-blue-50 rounded-lg border border-blue-200">
                <p className="text-xs text-gray-600 mb-1">Statement Balance</p>
                <p className="text-xl font-bold text-blue-600">{formatNaira(statementBalance)}</p>
              </div>
              <div className="p-4 bg-green-50 rounded-lg border border-green-200">
                <p className="text-xs text-gray-600 mb-1">Outstanding Credits</p>
                <p className="text-xl font-bold text-green-600">
                  +{formatNaira(outstandingItems.filter((item) => (item.type === "receipt" || item.type === "deposit") && item.status === "outstanding").reduce((sum, item) => sum + item.amount, 0))}
                </p>
              </div>
              <div className="p-4 bg-red-50 rounded-lg border border-red-200">
                <p className="text-xs text-gray-600 mb-1">Outstanding Debits</p>
                <p className="text-xl font-bold text-red-600">
                  -{formatNaira(outstandingItems.filter((item) => item.type === "check" && item.status === "outstanding").reduce((sum, item) => sum + item.amount, 0))}
                </p>
              </div>
              <div className={`p-4 rounded-lg border ${
                Math.abs(difference) < 1
                  ? "bg-green-50 border-green-200"
                  : "bg-yellow-50 border-yellow-200"
              }`}>
                <p className="text-xs text-gray-600 mb-1">Adjusted Balance</p>
                <p className={`text-xl font-bold ${
                  Math.abs(difference) < 1 ? "text-green-600" : "text-yellow-600"
                }`}>
                  {formatNaira(adjustedBalance)}
                </p>
                {Math.abs(difference) >= 1 && (
                  <p className="text-xs text-yellow-700 mt-1">
                    Difference: {formatNaira(Math.abs(difference))}
                  </p>
                )}
              </div>
            </div>

            {/* Tabs */}
            <div className="flex items-center gap-2 mb-4 border-b border-gray-200">
              <button
                className={`px-4 py-2 font-semibold text-sm border-b-2 transition-colors ${
                  selectedType === "all"
                    ? "border-primary-600 text-primary-600"
                    : "border-transparent text-gray-600 hover:text-gray-800"
                }`}
                onClick={() => setSelectedType("all")}
              >
                Bank Statement ({statementTransactions.length})
              </button>
              <button
                className={`px-4 py-2 font-semibold text-sm border-b-2 transition-colors ${
                  selectedType !== "all"
                    ? "border-primary-600 text-primary-600"
                    : "border-transparent text-gray-600 hover:text-gray-800"
                }`}
              >
                Outstanding Items ({outstandingItems.filter((item) => item.status === "outstanding").length})
              </button>
            </div>

            {/* Filters */}
            <div className="flex items-center gap-2 mb-4 flex-wrap">
              <div className="relative flex-1 min-w-[200px]">
                <Search size={16} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search transactions..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <select
                value={selectedType}
                onChange={(e) => setSelectedType(e.target.value as "all" | "debit" | "credit")}
                className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="all">All Types</option>
                <option value="credit">Credits Only</option>
                <option value="debit">Debits Only</option>
              </select>
              <label className="flex items-center gap-2 px-3 py-2 border border-gray-300 rounded-lg text-sm cursor-pointer hover:bg-gray-50">
                <input
                  type="checkbox"
                  checked={showMatched}
                  onChange={(e) => setShowMatched(e.target.checked)}
                  className="rounded"
                />
                <span>Show Matched</span>
              </label>
            </div>

            {/* Bank Statement Transactions */}
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-gray-800 mb-4">Bank Statement Transactions</h3>
              <div className="overflow-x-auto border border-gray-200 rounded-lg">
                <table className="w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                        Date
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                        Description
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                        Reference
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                        Type
                      </th>
                      <th className="px-4 py-3 text-right text-xs font-semibold text-gray-700 uppercase">
                        Amount
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase">
                        Status
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase">
                        Action
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {filteredTransactions.map((tx) => (
                      <tr
                        key={tx.id}
                        className={`hover:bg-gray-50 ${tx.matched ? "bg-green-50/30" : ""}`}
                      >
                        <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600">
                          {new Date(tx.date).toLocaleDateString()}
                        </td>
                        <td className="px-4 py-3 text-sm font-medium text-gray-800">{tx.description}</td>
                        <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600">
                          {tx.reference || "-"}
                        </td>
                        <td className="px-4 py-3 whitespace-nowrap">
                          <span
                            className={`px-2 py-1 rounded-full text-xs font-semibold ${
                              tx.type === "credit"
                                ? "bg-green-100 text-green-700"
                                : "bg-red-100 text-red-700"
                            }`}
                          >
                            {tx.type === "credit" ? "Credit" : "Debit"}
                          </span>
                        </td>
                        <td className={`px-4 py-3 whitespace-nowrap text-sm font-semibold text-right ${
                          tx.type === "credit" ? "text-green-600" : "text-red-600"
                        }`}>
                          {tx.type === "credit" ? "+" : "-"}
                          {formatNaira(tx.amount)}
                        </td>
                        <td className="px-4 py-3 whitespace-nowrap text-center">
                          {tx.matched ? (
                            <span className="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-semibold flex items-center justify-center gap-1">
                              <CheckCircle2 size={12} />
                              Matched
                            </span>
                          ) : (
                            <span className="px-2 py-1 bg-gray-100 text-gray-700 rounded-full text-xs font-semibold flex items-center justify-center gap-1">
                              <Clock size={12} />
                              Pending
                            </span>
                          )}
                        </td>
                        <td className="px-4 py-3 whitespace-nowrap text-center">
                          <button
                            onClick={() => handleMatchTransaction(tx.id)}
                            className={`px-3 py-1 rounded-lg text-xs font-semibold transition-colors ${
                              tx.matched
                                ? "bg-red-100 text-red-700 hover:bg-red-200"
                                : "bg-green-100 text-green-700 hover:bg-green-200"
                            }`}
                          >
                            {tx.matched ? "Unmatch" : "Match"}
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                {filteredTransactions.length === 0 && (
                  <div className="text-center py-8 text-gray-500">No transactions found.</div>
                )}
              </div>
            </div>

            {/* Outstanding Items */}
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-gray-800 mb-4">Outstanding Items</h3>
              <div className="overflow-x-auto border border-gray-200 rounded-lg">
                <table className="w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                        Date
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                        Type
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                        Description
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase">
                        Reference
                      </th>
                      <th className="px-4 py-3 text-right text-xs font-semibold text-gray-700 uppercase">
                        Amount
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase">
                        Status
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase">
                        Action
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {filteredOutstanding.map((item) => (
                      <tr
                        key={item.id}
                        className={`hover:bg-gray-50 ${item.status === "cleared" ? "bg-green-50/30" : ""}`}
                      >
                        <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600">
                          {new Date(item.date).toLocaleDateString()}
                        </td>
                        <td className="px-4 py-3 whitespace-nowrap">
                          <span
                            className={`px-2 py-1 rounded-full text-xs font-semibold ${
                              item.type === "check"
                                ? "bg-red-100 text-red-700"
                                : item.type === "receipt"
                                ? "bg-blue-100 text-blue-700"
                                : "bg-green-100 text-green-700"
                            }`}
                          >
                            {item.type.charAt(0).toUpperCase() + item.type.slice(1)}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-sm font-medium text-gray-800">{item.description}</td>
                        <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600">
                          {item.reference}
                        </td>
                        <td className={`px-4 py-3 whitespace-nowrap text-sm font-semibold text-right ${
                          item.type === "check" ? "text-red-600" : "text-green-600"
                        }`}>
                          {item.type === "check" ? "-" : "+"}
                          {formatNaira(item.amount)}
                        </td>
                        <td className="px-4 py-3 whitespace-nowrap text-center">
                          {item.status === "cleared" ? (
                            <span className="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-semibold">
                              Cleared
                            </span>
                          ) : (
                            <span className="px-2 py-1 bg-yellow-100 text-yellow-700 rounded-full text-xs font-semibold">
                              Outstanding
                            </span>
                          )}
                        </td>
                        <td className="px-4 py-3 whitespace-nowrap text-center">
                          <button
                            onClick={() => handleClearOutstanding(item.id)}
                            className={`px-3 py-1 rounded-lg text-xs font-semibold transition-colors ${
                              item.status === "cleared"
                                ? "bg-yellow-100 text-yellow-700 hover:bg-yellow-200"
                                : "bg-green-100 text-green-700 hover:bg-green-200"
                            }`}
                          >
                            {item.status === "cleared" ? "Mark Outstanding" : "Mark Cleared"}
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                {filteredOutstanding.length === 0 && (
                  <div className="text-center py-8 text-gray-500">No outstanding items found.</div>
                )}
              </div>
            </div>

            {/* Notes */}
            <div className="mb-6">
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                Reconciliation Notes
              </label>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="Add any notes or observations about this reconciliation..."
              />
            </div>

            {/* Reconciliation Status */}
            {Math.abs(difference) < 1 ? (
              <div className="p-4 bg-green-50 border border-green-200 rounded-lg mb-6">
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="text-green-600" size={20} />
                  <p className="text-sm font-semibold text-green-800">
                    Reconciliation is balanced! You can complete the reconciliation.
                  </p>
                </div>
              </div>
            ) : (
              <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg mb-6">
                <div className="flex items-center gap-2">
                  <AlertCircle className="text-yellow-600" size={20} />
                  <p className="text-sm font-semibold text-yellow-800">
                    There is a difference of {formatNaira(Math.abs(difference))}. Please review all transactions
                    before completing.
                  </p>
                </div>
              </div>
            )}
          </div>

          {/* Footer */}
          <div className="flex items-center justify-between p-6 border-t border-gray-200 bg-gray-50">
            <button
              onClick={onClose}
              className="px-4 py-2 border border-gray-300 rounded-lg text-sm font-semibold text-gray-700 hover:bg-gray-100 transition-colors"
            >
              Cancel
            </button>
            <div className="flex items-center gap-2">
              <button
                onClick={() => alert("Save draft functionality will be implemented")}
                className="px-4 py-2 border border-gray-300 rounded-lg text-sm font-semibold text-gray-700 hover:bg-gray-100 transition-colors"
              >
                Save Draft
              </button>
              <button
                onClick={handleCompleteReconciliation}
                disabled={Math.abs(difference) >= 1}
                className={`px-6 py-2 rounded-lg text-sm font-semibold text-white transition-colors ${
                  Math.abs(difference) >= 1
                    ? "bg-gray-400 cursor-not-allowed"
                    : "bg-primary-600 hover:bg-primary-700"
                }`}
              >
                Complete Reconciliation
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

