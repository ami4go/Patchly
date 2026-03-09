'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/layout/AppShell';
import api from '@/lib/api';
import { Plus, User, Search } from 'lucide-react';

interface Engineer {
  EngineerID: number;
  Name: string;
  Email: string;
  DepartmentName: string;
  CurrentWorkload: number;
  MaxWorkload: number;
  IsOnLeave: boolean;
}

export default function EngineersPage() {
  const [engineers, setEngineers] = useState<Engineer[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [departments, setDepartments] = useState<any[]>([]);
  const [skills, setSkills] = useState<any[]>([]);
  const [form, setForm] = useState({ name: '', email: '', departmentId: '', maxWorkload: '10', skillIds: [] as string[] });

  useEffect(() => {
    api.get('/engineers').then(r => setEngineers(r.data.data)).catch(console.error).finally(() => setLoading(false));
    api.get('/departments').then(r => setDepartments(r.data.data));
    api.get('/skills').then(r => setSkills(r.data.data));
  }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post('/engineers', {
        name: form.name,
        email: form.email,
        departmentId: parseInt(form.departmentId),
        maxWorkload: parseInt(form.maxWorkload),
        skillIds: form.skillIds.map(Number),
      });
      setShowModal(false);
      setForm({ name: '', email: '', departmentId: '', maxWorkload: '10', skillIds: [] });
      const r = await api.get('/engineers');
      setEngineers(r.data.data);
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to create engineer');
    }
  };

  const filtered = engineers.filter(e =>
    e.Name.toLowerCase().includes(search.toLowerCase()) ||
    e.Email.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <AppShell>
      <div className="p-8">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-2xl font-bold text-white">Engineers</h1>
            <p className="text-gray-400 mt-1">{engineers.length} total engineers</p>
          </div>
          <button
            onClick={() => setShowModal(true)}
            className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2.5 rounded-lg font-medium text-sm transition-colors"
          >
            <Plus className="w-4 h-4" />
            Add Engineer
          </button>
        </div>

        <div className="relative mb-6 max-w-sm">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search engineers..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full bg-gray-800 border border-gray-700 text-white pl-10 pr-4 py-2.5 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        {loading ? (
          <div className="text-center text-gray-400 py-12">Loading...</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {filtered.map(eng => {
              const workloadPct = Math.round((eng.CurrentWorkload / eng.MaxWorkload) * 100);
              return (
                <div key={eng.EngineerID} className="bg-gray-800 border border-gray-700 rounded-xl p-5">
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-indigo-600 rounded-full flex items-center justify-center text-white font-semibold">
                        {eng.Name.charAt(0)}
                      </div>
                      <div>
                        <p className="text-white font-medium">{eng.Name}</p>
                        <p className="text-gray-400 text-xs">{eng.Email}</p>
                      </div>
                    </div>
                    {eng.IsOnLeave && (
                      <span className="bg-yellow-900/40 text-yellow-400 text-xs px-2 py-0.5 rounded-full">On Leave</span>
                    )}
                  </div>
                  <p className="text-gray-400 text-sm mb-3">{eng.DepartmentName}</p>
                  <div>
                    <div className="flex justify-between text-xs text-gray-400 mb-1">
                      <span>Workload</span>
                      <span>{eng.CurrentWorkload}/{eng.MaxWorkload}</span>
                    </div>
                    <div className="w-full bg-gray-700 rounded-full h-1.5">
                      <div
                        className={`h-1.5 rounded-full ${workloadPct > 80 ? 'bg-red-500' : workloadPct > 50 ? 'bg-yellow-500' : 'bg-green-500'}`}
                        style={{ width: `${workloadPct}%` }}
                      />
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
          <div className="bg-gray-800 border border-gray-700 rounded-2xl p-6 w-full max-w-lg">
            <h2 className="text-white font-semibold text-lg mb-6">Add Engineer</h2>
            <form onSubmit={handleCreate} className="space-y-4">
              <div>
                <label className="block text-sm text-gray-300 mb-1.5">Name *</label>
                <input required value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))}
                  className="w-full bg-gray-900 border border-gray-600 text-white rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500" />
              </div>
              <div>
                <label className="block text-sm text-gray-300 mb-1.5">Email *</label>
                <input required type="email" value={form.email} onChange={e => setForm(f => ({ ...f, email: e.target.value }))}
                  className="w-full bg-gray-900 border border-gray-600 text-white rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm text-gray-300 mb-1.5">Department *</label>
                  <select required value={form.departmentId} onChange={e => setForm(f => ({ ...f, departmentId: e.target.value }))}
                    className="w-full bg-gray-900 border border-gray-600 text-white rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
                    <option value="">Select</option>
                    {departments.map(d => <option key={d.DepartmentID} value={d.DepartmentID}>{d.DepartmentName}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-sm text-gray-300 mb-1.5">Max Workload</label>
                  <input type="number" min="1" value={form.maxWorkload} onChange={e => setForm(f => ({ ...f, maxWorkload: e.target.value }))}
                    className="w-full bg-gray-900 border border-gray-600 text-white rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
              </div>
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setShowModal(false)}
                  className="flex-1 bg-gray-700 hover:bg-gray-600 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors">
                  Cancel
                </button>
                <button type="submit"
                  className="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors">
                  Add Engineer
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </AppShell>
  );
}
