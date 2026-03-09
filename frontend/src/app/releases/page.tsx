'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/layout/AppShell';
import api from '@/lib/api';
import { Plus, Package, RotateCcw } from 'lucide-react';

const STATUS_COLORS: Record<string, string> = {
  PENDING: 'bg-yellow-900/40 text-yellow-300',
  DEPLOYED: 'bg-blue-900/40 text-blue-300',
  STABLE: 'bg-green-900/40 text-green-300',
  'ROLLED BACK': 'bg-red-900/40 text-red-300',
};

export default function ReleasesPage() {
  const [releases, setReleases] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/releases').then(r => setReleases(r.data.data)).finally(() => setLoading(false));
  }, []);

  const handleRollback = async (id: number) => {
    if (!confirm('Are you sure you want to rollback this release?')) return;
    try {
      await api.post(`/releases/${id}/rollback`, { reason: 'Manual rollback' });
      const r = await api.get('/releases');
      setReleases(r.data.data);
    } catch (err: any) {
      alert(err.response?.data?.message || 'Rollback failed');
    }
  };

  const handleUpdateStatus = async (id: number, status: string) => {
    try {
      await api.put(`/releases/${id}/status`, { deploymentStatus: status });
      const r = await api.get('/releases');
      setReleases(r.data.data);
    } catch (err: any) {
      alert(err.response?.data?.message || 'Update failed');
    }
  };

  return (
    <AppShell>
      <div className="p-8">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-white">Releases</h1>
          <p className="text-gray-400 mt-1">{releases.length} total releases</p>
        </div>

        {loading ? (
          <div className="text-center text-gray-400 py-12">Loading...</div>
        ) : releases.length === 0 ? (
          <div className="text-center text-gray-400 py-12">No releases found</div>
        ) : (
          <div className="space-y-4">
            {releases.map((rel) => (
              <div key={rel.ReleaseID} className="bg-gray-800 border border-gray-700 rounded-xl p-6">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 bg-indigo-600/20 border border-indigo-500/30 rounded-lg flex items-center justify-center">
                      <Package className="w-5 h-5 text-indigo-400" />
                    </div>
                    <div>
                      <p className="text-white font-medium">{rel.AppName} v{rel.VersionNumber}</p>
                      <p className="text-gray-400 text-sm">
                        {rel.ReleaseDate ? new Date(rel.ReleaseDate).toLocaleDateString() : 'Date TBD'}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className={`px-3 py-1 text-xs font-medium rounded-full ${STATUS_COLORS[rel.DeploymentStatus] || 'bg-gray-700 text-gray-300'}`}>
                      {rel.DeploymentStatus}
                    </span>
                    {rel.DeploymentStatus === 'DEPLOYED' && (
                      <>
                        <button
                          onClick={() => handleUpdateStatus(rel.ReleaseID, 'STABLE')}
                          className="text-xs bg-green-700 hover:bg-green-600 text-white px-3 py-1.5 rounded-lg transition-colors"
                        >
                          Mark Stable
                        </button>
                        <button
                          onClick={() => handleRollback(rel.ReleaseID)}
                          className="flex items-center gap-1 text-xs bg-red-700 hover:bg-red-600 text-white px-3 py-1.5 rounded-lg transition-colors"
                        >
                          <RotateCcw className="w-3 h-3" />
                          Rollback
                        </button>
                      </>
                    )}
                    {rel.DeploymentStatus === 'PENDING' && (
                      <button
                        onClick={() => handleUpdateStatus(rel.ReleaseID, 'DEPLOYED')}
                        className="text-xs bg-blue-700 hover:bg-blue-600 text-white px-3 py-1.5 rounded-lg transition-colors"
                      >
                        Deploy
                      </button>
                    )}
                  </div>
                </div>
                {rel.Notes && (
                  <p className="text-gray-400 text-sm mt-3 border-t border-gray-700 pt-3">{rel.Notes}</p>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </AppShell>
  );
}
