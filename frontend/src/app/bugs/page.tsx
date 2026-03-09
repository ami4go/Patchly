'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/layout/AppShell';
import api from '@/lib/api';
import { Plus, Bug, Filter, Search, ChevronLeft, ChevronRight } from 'lucide-react';

const PRIORITY_COLORS: Record<string, string> = {
  CRITICAL: 'bg-red-900/50 text-red-400 border-red-700',
  HIGH: 'bg-orange-900/50 text-orange-400 border-orange-700',
  MEDIUM: 'bg-yellow-900/50 text-yellow-400 border-yellow-700',
  LOW: 'bg-blue-900/50 text-blue-400 border-blue-700',
};

const STATUS_COLORS: Record<string, string> = {
  OPEN: 'bg-red-900/40 text-red-300',
  'IN PROGRESS': 'bg-blue-900/40 text-blue-300',
  RESOLVED: 'bg-green-900/40 text-green-300',
  CLOSED: 'bg-gray-900/40 text-gray-400',
  REOPENED: 'bg-orange-900/40 text-orange-300',
};

interface Bug {
  BugID: number;
  Title: string;
  Description: string;
  CreatedAt: string;
  SourceType: string;
  PriorityLevel: string;
  StatusName: string;
  CategoryName: string;
}

export default function BugsPage() {
  const [bugs, setBugs] = useState<Bug[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [priorityFilter, setPriorityFilter] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [priorities, setPriorities] = useState<any[]>([]);
  const [statuses, setStatuses] = useState<any[]>([]);
  const [categories, setCategories] = useState<any[]>([]);
  const [form, setForm] = useState({ title: '', description: '', priorityId: '', statusId: '', categoryId: '' });
  const limit = 10;

  const fetchBugs = () => {
    setLoading(true);
    const params: any = { page, limit };
    if (statusFilter) params.status = statusFilter;
    if (priorityFilter) params.priority = priorityFilter;
    api.get('/bugs', { params })
      .then((r) => { setBugs(r.data.data); setTotal(r.data.total); })
      .catch(console.error)
      .finally(() => setLoading(false));
  };

  useEffect(() => { fetchBugs(); }, [page, statusFilter, priorityFilter]);
  useEffect(() => {
    api.get('/priorities').then(r => setPriorities(r.data.data));
    api.get('/statuses').then(r => setStatuses(r.data.data));
    api.get('/categories').then(r => setCategories(r.data.data));
  }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post('/bugs', {
        title: form.title,
        description: form.description,
        priorityId: parseInt(form.priorityId),
        statusId: parseInt(form.statusId),
        categoryId: form.categoryId ? parseInt(form.categoryId) : undefined,
      });
      setShowModal(false);
      setForm({ title: '', description: '', priorityId: '', statusId: '', categoryId: '' });
      fetchBugs();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to create bug');
    }
  };

  const filtered = search
    ? bugs.filter(b => b.Title.toLowerCase().includes(search.toLowerCase()))
    : bugs;

  const totalPages = Math.ceil(total / limit);

  return (
    <AppShell>
      <div className="p-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-2xl font-bold text-white">Bug Tracker</h1>
            <p className="text-gray-400 mt-1">{total} total bugs</p>
          </div>
          <button
            onClick={() => setShowModal(true)}
            className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2.5 rounded-lg font-medium text-sm transition-colors"
          >
            <Plus className="w-4 h-4" />
            New Bug
          </button>
        </div>

        {/* Filters */}
        <div className="flex gap-3 mb-6 flex-wrap">
          <div className="relative flex-1 min-w-64">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search bugs..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="w-full bg-gray-800 border border-gray-700 text-white pl-10 pr-4 py-2.5 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <select
            value={statusFilter}
            onChange={e => { setStatusFilter(e.target.value); setPage(1); }}
            className="bg-gray-800 border border-gray-700 text-gray-300 px-4 py-2.5 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <option value="">All Statuses</option>
            <option value="OPEN">Open</option>
            <option value="IN PROGRESS">In Progress</option>
            <option value="RESOLVED">Resolved</option>
            <option value="CLOSED">Closed</option>
          </select>
          <select
            value={priorityFilter}
            onChange={e => { setPriorityFilter(e.target.value); setPage(1); }}
            className="bg-gray-800 border border-gray-700 text-gray-300 px-4 py-2.5 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <option value="">All Priorities</option>
            <option value="CRITICAL">Critical</option>
            <option value="HIGH">High</option>
            <option value="MEDIUM">Medium</option>
            <option value="LOW">Low</option>
          </select>
        </div>

        {/* Table */}
        <div className="bg-gray-800 border border-gray-700 rounded-xl overflow-hidden">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-700 bg-gray-900/50">
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">ID</th>
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Title</th>
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Priority</th>
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Status</th>
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Category</th>
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Created</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-700">
              {loading ? (
                <tr>
                  <td colSpan={6} className="text-center text-gray-400 py-12">Loading...</td>
                </tr>
              ) : filtered.length === 0 ? (
                <tr>
                  <td colSpan={6} className="text-center text-gray-400 py-12">No bugs found</td>
                </tr>
              ) : filtered.map((bug) => (
                <tr key={bug.BugID} className="hover:bg-gray-700/50 transition-colors">
                  <td className="px-6 py-4 text-gray-400 text-sm">#{bug.BugID}</td>
                  <td className="px-6 py-4">
                    <p className="text-white text-sm font-medium">{bug.Title}</p>
                    {bug.Description && (
                      <p className="text-gray-500 text-xs mt-0.5 truncate max-w-xs">{bug.Description}</p>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <span className={`px-2.5 py-1 text-xs font-medium rounded-full border ${PRIORITY_COLORS[bug.PriorityLevel] || 'bg-gray-700 text-gray-300'}`}>
                      {bug.PriorityLevel}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <span className={`px-2.5 py-1 text-xs font-medium rounded-full ${STATUS_COLORS[bug.StatusName] || 'bg-gray-700 text-gray-300'}`}>
                      {bug.StatusName}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-gray-300 text-sm">{bug.CategoryName || '—'}</td>
                  <td className="px-6 py-4 text-gray-400 text-xs">
                    {new Date(bug.CreatedAt).toLocaleDateString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-between mt-4">
            <p className="text-gray-400 text-sm">Page {page} of {totalPages}</p>
            <div className="flex gap-2">
              <button
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="p-2 bg-gray-800 border border-gray-700 rounded-lg text-gray-400 hover:text-white disabled:opacity-40"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button
                onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
                className="p-2 bg-gray-800 border border-gray-700 rounded-lg text-gray-400 hover:text-white disabled:opacity-40"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Create Bug Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
          <div className="bg-gray-800 border border-gray-700 rounded-2xl p-6 w-full max-w-lg">
            <h2 className="text-white font-semibold text-lg mb-6">Create New Bug</h2>
            <form onSubmit={handleCreate} className="space-y-4">
              <div>
                <label className="block text-sm text-gray-300 mb-1.5">Title *</label>
                <input
                  required
                  value={form.title}
                  onChange={e => setForm(f => ({ ...f, title: e.target.value }))}
                  className="w-full bg-gray-900 border border-gray-600 text-white rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
              <div>
                <label className="block text-sm text-gray-300 mb-1.5">Description</label>
                <textarea
                  rows={3}
                  value={form.description}
                  onChange={e => setForm(f => ({ ...f, description: e.target.value }))}
                  className="w-full bg-gray-900 border border-gray-600 text-white rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 resize-none"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm text-gray-300 mb-1.5">Priority *</label>
                  <select
                    required
                    value={form.priorityId}
                    onChange={e => setForm(f => ({ ...f, priorityId: e.target.value }))}
                    className="w-full bg-gray-900 border border-gray-600 text-white rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  >
                    <option value="">Select priority</option>
                    {priorities.map(p => (
                      <option key={p.PriorityID} value={p.PriorityID}>{p.PriorityLevel}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm text-gray-300 mb-1.5">Status *</label>
                  <select
                    required
                    value={form.statusId}
                    onChange={e => setForm(f => ({ ...f, statusId: e.target.value }))}
                    className="w-full bg-gray-900 border border-gray-600 text-white rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  >
                    <option value="">Select status</option>
                    {statuses.map(s => (
                      <option key={s.StatusID} value={s.StatusID}>{s.StatusName}</option>
                    ))}
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm text-gray-300 mb-1.5">Category</label>
                <select
                  value={form.categoryId}
                  onChange={e => setForm(f => ({ ...f, categoryId: e.target.value }))}
                  className="w-full bg-gray-900 border border-gray-600 text-white rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                >
                  <option value="">Select category</option>
                  {categories.map(c => (
                    <option key={c.CategoryID} value={c.CategoryID}>{c.CategoryName}</option>
                  ))}
                </select>
              </div>
              <div className="flex gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="flex-1 bg-gray-700 hover:bg-gray-600 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors"
                >
                  Create Bug
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </AppShell>
  );
}
