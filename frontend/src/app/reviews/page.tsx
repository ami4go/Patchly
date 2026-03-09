'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/layout/AppShell';
import api from '@/lib/api';
import { Star } from 'lucide-react';

export default function ReviewsPage() {
  const [reviews, setReviews] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/reviews').then(r => setReviews(r.data.data)).finally(() => setLoading(false));
  }, []);

  const renderStars = (rating: number) => {
    return Array.from({ length: 5 }, (_, i) => (
      <Star
        key={i}
        className={`w-4 h-4 ${i < rating ? 'text-yellow-400 fill-yellow-400' : 'text-gray-600'}`}
      />
    ));
  };

  return (
    <AppShell>
      <div className="p-8">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-white">User Reviews</h1>
          <p className="text-gray-400 mt-1">{reviews.length} total reviews</p>
        </div>

        {loading ? (
          <div className="text-center text-gray-400 py-12">Loading...</div>
        ) : reviews.length === 0 ? (
          <div className="text-center text-gray-400 py-12">No reviews yet</div>
        ) : (
          <div className="space-y-4">
            {reviews.map(review => (
              <div key={review.ReviewID} className="bg-gray-800 border border-gray-700 rounded-xl p-5">
                <div className="flex items-start justify-between mb-2">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 bg-indigo-600 rounded-full flex items-center justify-center text-white font-semibold text-sm">
                      {review.UserName?.charAt(0) || '?'}
                    </div>
                    <div>
                      <p className="text-white font-medium">{review.UserName}</p>
                      <p className="text-gray-500 text-xs">{review.AppName}</p>
                    </div>
                  </div>
                  <div className="flex flex-col items-end gap-1">
                    <div className="flex gap-0.5">{renderStars(review.Rating)}</div>
                    <p className="text-gray-500 text-xs">{new Date(review.Timestamp).toLocaleDateString()}</p>
                  </div>
                </div>
                {review.Content && (
                  <p className="text-gray-300 text-sm leading-relaxed">{review.Content}</p>
                )}
                {review.SentimentScore !== null && (
                  <div className="mt-3 inline-flex items-center gap-1.5">
                    <span className="text-xs text-gray-500">Sentiment:</span>
                    <span className={`text-xs font-medium px-2 py-0.5 rounded-full ${
                      review.SentimentScore >= 0.5 ? 'bg-green-900/40 text-green-400' :
                      review.SentimentScore >= 0 ? 'bg-yellow-900/40 text-yellow-400' :
                      'bg-red-900/40 text-red-400'
                    }`}>
                      {review.SentimentScore?.toFixed(2)}
                    </span>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </AppShell>
  );
}
