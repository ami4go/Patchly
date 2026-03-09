'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/layout/AppShell';
import api from '@/lib/api';
import { Shield, AlertTriangle, DollarSign } from 'lucide-react';

export default function SLAPage() {
  const [slas, setSlas] = useState<any[]>([]);
  const [penalties, setPenalties] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      api.get('/sla/slas'),
      api.get('/sla/penalties'),
    ]).then(([slaRes, penRes]) => {
      setSlas(slaRes.data.data);
      setPenalties(penRes.data.data);
    }).finally(() => setLoading(false));
  }, []);

  const totalPenalty = penalties.reduce((sum, p) => sum + p.Amount, 0);

  return (
    <AppShell>
      <div className="p-8">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-white">SLA & Penalties</h1>
          <p className="text-gray-400 mt-1">Service Level Agreement monitoring and breach tracking</p>
        </div>

        {/* Summary */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
          <div className="bg-gray-800 border border-gray-700 rounded-xl p-5">
            <Shield className="w-8 h-8 text-indigo-400 mb-3" />
            <p className="text-gray-400 text-sm">SLA Agreements</p>
            <p className="text-3xl font-bold text-white">{slas.length}</p>
          </div>
          <div className="bg-gray-800 border border-gray-700 rounded-xl p-5">
            <AlertTriangle className="w-8 h-8 text-red-400 mb-3" />
            <p className="text-gray-400 text-sm">Breaches</p>
            <p className="text-3xl font-bold text-white">{penalties.length}</p>
          </div>
          <div className="bg-gray-800 border border-gray-700 rounded-xl p-5">
            <DollarSign className="w-8 h-8 text-yellow-400 mb-3" />
            <p className="text-gray-400 text-sm">Total Penalties</p>
            <p className="text-3xl font-bold text-white">${totalPenalty.toLocaleString()}</p>
          </div>
        </div>

        {/* SLA Table */}
        <div className="bg-gray-800 border border-gray-700 rounded-xl overflow-hidden mb-6">
          <div className="px-6 py-4 border-b border-gray-700">
            <h2 className="text-white font-semibold">SLA Definitions</h2>
          </div>
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-700 bg-gray-900/50">
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Priority</th>
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Max Resolution Hours</th>
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Penalty Cost</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-700">
              {loading ? (
                <tr><td colSpan={3} className="text-center text-gray-400 py-8">Loading...</td></tr>
              ) : slas.map(sla => (
                <tr key={sla.SLAID} className="hover:bg-gray-700/30">
                  <td className="px-6 py-4 text-white font-medium">{sla.PriorityLevel}</td>
                  <td className="px-6 py-4 text-gray-300">{sla.MaxResolutionHours}h</td>
                  <td className="px-6 py-4 text-gray-300">${sla.PenaltyCost?.toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Penalties Table */}
        <div className="bg-gray-800 border border-gray-700 rounded-xl overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-700">
            <h2 className="text-white font-semibold">Penalty Records</h2>
          </div>
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-700 bg-gray-900/50">
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Bug</th>
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Amount</th>
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Reason</th>
                <th className="text-left text-xs font-medium text-gray-400 uppercase px-6 py-3">Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-700">
              {penalties.length === 0 ? (
                <tr><td colSpan={4} className="text-center text-gray-400 py-8">No penalties recorded</td></tr>
              ) : penalties.map(p => (
                <tr key={p.PenaltyID} className="hover:bg-gray-700/30">
                  <td className="px-6 py-4 text-white text-sm">{p.BugTitle}</td>
                  <td className="px-6 py-4 text-red-400 font-medium">${p.Amount?.toLocaleString()}</td>
                  <td className="px-6 py-4 text-gray-400 text-sm">{p.Reason || '—'}</td>
                  <td className="px-6 py-4 text-gray-400 text-xs">{new Date(p.CreatedAt).toLocaleDateString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AppShell>
  );
}
